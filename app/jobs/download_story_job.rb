class DownloadStoryJob < ApplicationJob
  queue_as :default

  def perform(story)
    @story = story
    url = @story.thread_url.chomp('/')
    Rails.logger.info(url)

    Rails.logger.info("[StoryDownload] Downloading story at URL #{url}")

    chapter_data = parse_threadmarks(url)
    Rails.logger.info(chapter_data)

    # This means a URL was passed which does not have any threadmarks so nothing can be downloaded.
    if chapter_data.empty?
      Rails.logger.error("[StoryDownload] No story with threadmarks was found at #{url}")
      @story.destroy
      return
    end

    set_story_metadata(url)
    Rails.logger.info("[StoryDownload] Author metadata: #{@metadata}")

    # filename = build_filename(url)
    # Rails.logger.info("[StoryDownload] Saving to file #{filename}")

    @chapter_data = build_story_body(chapter_data)

  end

  def persist_chapters
    @chapter_data.each do |ch|
      puts ch[:title]
    end
  end

  def parse_threadmarks(url)
    url += '/threadmarks'
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

  def set_story_metadata(url)
    url += '/threadmarks'
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
