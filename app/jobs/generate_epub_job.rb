class GenerateEpubJob < ApplicationJob
  queue_as :default

  def perform(story_id)
    @story = Story.find(story_id)
    @chapters = Chapter.where(story_id: @story.id)
    Rails.logger.info("[GenerateEpub] Generating ePub for #{@story.title}")

    @epub = GEPUB::Book.new

    build_filename
    add_metadata
    generate_chapter_bodies
    add_chapters
    save_file
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
    html = "<html><head>
      <title>#{chapter.title}</title>
      </head>
      <body>
      #{chapter.body.html_safe}
      </body>
      </html>"

    body = convert_to_xhtml(html)
    StringIO.new(body)
  end

  def convert_to_xhtml(html)
    doc = Nokogiri::HTML.parse(html)
    doc.to_xhtml
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
    path = File.join(File.dirname(Rails.configuration.x.temp_storage_path), @filename)
    @epub.generate_epub(path)
    @story.epub.attach(io: File.open(path), filename: path)
  end
end
