class StoriesController < ApplicationController
  def index
    @stories = Story.all
  end

  def new
    @story = Story.new
  end

  def create
    params = submit_story_params

    if valid_url?(params[:thread_url])
      create_or_update_story(params)
      Rails.logger.info("[NewStory] Submitted with URL: #{params[:thread_url]}")
      redirect_to '/index'
    else
      Rails.logger.error("[NewStory] Submitted invalid URL: #{params[:thread_url]}")
      redirect_to '/new?invalidurl'
    end
  end

  def view
    @story = Story.find(params[:id])
    @chapters = Chapters.find_by(thread_url: @story.thread_url)
  end

  private

  def submit_story_params
    params.require(:story).permit(:thread_url)
  end

  def create_or_update_story(params)
    thread_url = params[:thread_url]
    thread_url = thread_url.chomp('/')

    if Story.find_by(thread_url: thread_url)
      story = Story.find_by(thread_url: thread_url)
      story.refresh_story = true
    else
      story = Story.create(thread_url: thread_url)
    end

    story.save
  end

  def valid_url?(url)
    uri = URI.parse(url)
    uri.is_a?(URI::HTTP) && !uri.host.nil?
  rescue URI::InvalidURIError
    false
  end

end
