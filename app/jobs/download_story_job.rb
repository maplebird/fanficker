class DownloadStoryJob < ApplicationJob
  queue_as :default

  def perform(story)
    @story = story
    @thread_url = @story.thread_url.chomp('/')
    Rails.logger.info(@thread_url)

    Rails.logger.info("[StoryDownload] Downloading story at URL #{@thread_url}")

    chapter_data = parse_threadmarks
    Rails.logger.info(chapter_data)

    # This means a URL was passed which does not have any threadmarks so nothing can be downloaded.
    if chapter_data.empty?
      Rails.logger.error("[StoryDownload] No story with threadmarks was found at #{@thread_url}")
      @story.destroy
      return
    end

    set_story_metadata

    # filename = build_filename(url)
    # Rails.logger.info("[StoryDownload] Saving to file #{filename}")

    @chapter_data = build_story_body(chapter_data)

    persist_chapters

  end

  def persist_chapters
    @chapter_data.each do |ch|
      Rails.logger.info(thread_url: @thread_url, threadmark: ch[:threadmark])

      if Chapter.find_by(thread_url: @thread_url, threadmark: ch[:threadmark])
        Rails.logger.info("[StoryDownload] Updating chapter #{ch[:title]}")
        chapter = Chapter.find_by(thread_url: @thread_url, threadmark: ch[:threadmark])
      else
        Rails.logger.info("[StoryDownload] Persisting chapter #{ch[:title]}")
        chapter = Chapter.new
      end

      chapter.story = @story
      chapter.thread_url = @thread_url
      chapter.title = ch[:title]
      chapter.threadmark = ch[:threadmark]
      chapter.body = ch[:body]

      chapter.save!
    end
  end

  def parse_threadmarks
    url = @thread_url + '/threadmarks'
    base_url = base_url(url)
    doc = get_doc(url)
    doc = doc.css("[class='structItem-title threadmark_depth0']")
    chapters = []

    return if doc.empty?

    doc.each_with_index do |ch, index|
      metadata = {}
      link = ch.at_css('a')

      metadata[:title] = link.text
      metadata[:url] = base_url + ch.at_css('a')['data-preview-url']
      metadata[:threadmark] = index + 1

      chapters.append(metadata)
    end

    chapters
  end

  def set_story_metadata
    url = @thread_url + '/threadmarks'
    doc = get_doc(url)
    base_url = base_url(url)

    author = doc.search('.username').first

    @story.author = author.text
    @story.author_profile = base_url + author['href']
    @story.title = doc.search('.threadmarkListingHeader-name').text.strip
    @story.description = doc.search('.threadmarkListingHeader-extraInfoChild').search('.bbWrapper').text
    @story.save
  end

  def build_story_body(chapters)
    chapters.each do |ch|
      Rails.logger.info("[StoryDownload] Downloading #{ch[:title]}")
      ch[:body] = get_post_text(ch[:url])
    end

    chapters
  end

  def get_post_text(url)
    doc = get_doc(url)
    body = doc.search('.bbWrapper')

    'Could not get chapter text.' if body.empty? || body.nil?

    body.to_s
  end

  def build_filename(url)
    parsed = parse_url(url)
    name = parsed.path.split('/').last
    file = name.split('.')[0]  # Remove numeric thread ID
    file + '.html'
  end

  def parse_url(url)
    URI.parse(url)
  end

  def base_url(url)
    parsed = parse_url(url)
    parsed.scheme + '://' + parsed.host
  end

  def get_doc(url)
    Nokogiri::HTML(URI.open(url))
  rescue OpenURI::HTTPError
    Rails.logger.error("[StoryDownload] Could not open link URL at #{url}")
    false
  end
end
