class DownloadStoryJob < ApplicationJob
  queue_as :default

  def perform(thread_url)
    Rails.logger.info(thread_url)
    url = thread_url.chomp('/')
    @story = Story.find_by(thread_url: url)

    Rails.logger.info("[StoryDownload] Downloading story at URL #{url}")

    chapters = parse_threadmarks(url)
    Rails.logger.info(chapters)

    # This means a URL was passed which does not have any threadmarks so nothing can be downloaded.
    if chapters.empty?
      Rails.logger.error("[StoryDownload] No story with threadmarks was found at #{url}")
      @story.destroy
      return
    end

    metadata = get_story_metadata(url)
    Rails.logger.info("[StoryDownload] Author metadata: #{metadata}")

    filename = build_filename(thread_url)
    Rails.logger.info("[StoryDownload] Saving to file #{filename}")

    chapters = build_story_body(chapters)
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

  def get_story_metadata(url)
    url += '/threadmarks'
    doc = get_doc(url)
    base_url = base_url(url)
    metadata = {}

    metadata[:title] = doc.search('.threadmarkListingHeader-name').text.strip
    metadata[:description] = doc.search('.threadmarkListingHeader-extraInfoChild').search('.bbWrapper').text

    author = doc.search('.username').first
    metadata[:author] = author.text
    metadata[:author_profile] = base_url + author['href']

    metadata
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
