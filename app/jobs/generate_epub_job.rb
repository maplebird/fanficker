class GenerateEpubJob < ApplicationJob
  queue_as :default

  def perform(story)
    @story = story
    @chapters = Chapter.where(story_id: @story.id)
    Rails.logger.info("[GenerateEpub] Generating ePub for #{@story.title}")

    @epub = GEPUB::Book.new

    build_filename
    add_metadata
    generate_chapter_bodies
    add_chapters

    @epub
  end

  def add_metadata
    Rails.logger.info("[GenerateEpub] Adding book metadata for #{@story.title}")
    @epub.add_identifier(@story.thread_url, @story.title)
    @epub.language = 'en'

    @epub.add_title @story.title,
                    title_type: GEPUB::TITLE_TYPE::MAIN,
                    lang: 'en',
                    file_as: @story.title,
                    display_seq: 1

    @epub.add_creator @story.author
  end

  def build_filename
    uri = URI.parse(@story.thread_url)
    path = uri.path
    name = path.split('/').last
    @filename = name.split('.').first + '.epub'
    Rails.logger.info("[GenerateEpub] Book will be saved to #{@filename}")
  end

  def add_title
    @epub.ordered do
      @epub.add_item('text/cover.xhtml',
                     content: StringIO.new(<<-COVER)).landmark(type: 'cover', title: 'cover page')
                     <html xmlns="http://www.w3.org/1999/xhtml">
                     <head>
                       <title>#{@story.title}</title>
                     </head>
                     <body>
                     <h1>#{@story.title}</h1>
                     <h2>#{@story.author}</h2>
                     </body></html>
                     COVER
    end
  end

  def generate_body(chapter)
    body = StringIO.new(<<-CHAPTER_DIVIDER)
      <html xmlns="http://www.w3.org/1999/xhtml">
      <head><title>#{chapter.title}</title></head>
      <body>
      #{chapter.body.html_safe}
      </body>
    CHAPTER_DIVIDER

    body
  end

  def generate_chapter_bodies
    @chapter_content = []
    @chapters.each do |ch|
      map = {}

      map[:threadmark] = ch.threadmark.to_s
      map[:title] = ch.title
      map[:body] = generate_body(ch)

      @chapter_content.append(map)
    end
  end

  def add_chapters
    @epub.ordered do
      @chapter_content.each do |ch|
        @epub.add_item("text/chapter-#{ch[:threadmark]}.xhtml").add_content(ch[:body]).toc_text(ch[:title])
      end
    end
  end

  def save_file
    epubname = File.join(File.dirname(__FILE__), @filename)
    @epub.generate_epub(epubname)
  end
end
