class DownloadStoryJob < ApplicationJob
  queue_as :default
  discard_on 'StoryDownloadError'

  def perform(story_id)
    @story = Story.find(story_id)
    @thread_url = @story.thread_url.chomp('/')
    Rails.logger.info("[StoryDownload] Downloading story at URL #{@thread_url}")

    @chapters = parse_threadmarks
    validate_chapters

    set_story_metadata
    build_story_body
    persist_chapters

    @story.update(download_complete: true)
    trigger_generate_ebub
  end

  private

  def trigger_generate_ebub
    Rails.logger.info("[DownloadStory] Story id #{@story.id} queued up for ePub creation.")
    GenerateEpubJob.perform_later(@story.id)
  end

  def persist_chapters
    @chapters.each do |ch|
      filter = { story_id: @story.id, threadmark: ch[:threadmark] }

      chapter = Chapter.find_by(filter) || Chapter.new

      Rails.logger.info("[StoryDownload] Persisting chapter #{ch[:title]}")
      persist_chapter(chapter, ch)
    end
  end

  def persist_chapter(chapter, data)
    chapter.story_id = @story.id
    chapter.title = data[:title]
    chapter.threadmark = data[:threadmark]
    chapter.body = data[:body]
    chapter.save!
  end

  def parse_threadmarks
    url = @thread_url + '/threadmarks'
    base_url = base_url(url)
    doc = get_doc(url)
    doc = doc.css("[class='structItem-title threadmark_depth0']")

    begin
      doc = doc.css("[class='structItem-title threadmark_depth0']")
      Rails.logger.info('[StoryDownload] Found threadmarks page, parsing')
    rescue NoMethodError
      Rails.logger.error('[StoryDownload] Threadmarks CSS element not present.')
      return nil
    end

    chapters = []

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

  def build_story_body
    @chapters.each do |ch|
      Rails.logger.info("[StoryDownload] Downloading #{ch[:title]}")
      ch[:body] = get_post_text(ch[:url])
    end
  end

  def get_post_text(url)
    doc = get_doc(url)
    body = doc.search('.bbWrapper')

    'Could not get chapter text.' if body.empty? || body.nil?

    body.to_s
  end

  def parse_url(url)
    URI.parse(url)
  end

  def base_url(url)
    parsed = parse_url(url)
    parsed.scheme + '://' + parsed.host
  end

  def validate_chapters
    return unless @chapters.nil?

    Rails.logger.error('[StoryDownload] Threadmarks page empty, cannot download story. Aborting.')
    @story.destroy
    raise('StoryDownloadError')
  end

  def get_doc(url)
    3.times do |i|
      return Nokogiri::HTML(URI.open(url))
    rescue OpenURI::HTTPError
      Rails.logger.error("[StoryDownload] Could not open link URL at #{url}")
      i < 2 ? retry : false
    end
  end
end
