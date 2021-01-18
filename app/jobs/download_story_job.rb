class DownloadStoryJob < ApplicationJob
  queue_as :default

  def perform(params)
    thread_url = params[:thread_url].chomp('/')
    threadmarks_url = thread_url + '/threadmarks'

    Rails.logger.info("Downloading story at URL #{thread_url}")

    chapters = parse_threadmarks(threadmarks_url)
    Rails.logger.info(chapters)

    return if chapters.empty?

    if Story.exists?(thread_url: thread_url)
      story = Story.find_by(thread_url: thread_url)
      unless story.chapters.nil? or story.file_location.nil?
        return if story.chapters == chapters.count
      end
    end

    metadata = get_story_metadata(threadmarks_url)
    Rails.logger.info("Author metadata: #{metadata}")

    filename = build_filename(thread_url)
    Rails.logger.info("Saving to file #{filename}")
  end

  def parse_threadmarks(url)
    base_url = base_url(url)
    doc = get_doc(url)
    doc = doc.css("[class='structItem-title threadmark_depth0']")
    threadmark_counter = 1  # Arrays start at 1 if you're doing table of contents
    chapters = []

    return if doc.empty?

    doc.each do |ch|
      metadata = {}
      link = ch.at_css('a')

      metadata[:title] = link.text
      metadata[:url] = base_url + ch.at_css('a')['data-preview-url']
      metadata[:threadmark] = threadmark_counter

      threadmark_counter += 1
      chapters.append(metadata)
    end

    chapters
  end

  def get_story_metadata(url)
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
    
  private

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
  end

end
