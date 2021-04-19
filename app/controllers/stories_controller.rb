class StoriesController < ApplicationController
  before_action do
    ActiveStorage::Current.host = request.base_url
  end

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
      Rails.logger.info("[NewStory] Generate ePub: #{params[:generate_epub]}")
      redirect_to '/new?downloadInProgress'
    else
      Rails.logger.error("[NewStory] Submitted invalid URL: #{params[:thread_url]}")
      redirect_to '/new?invalidurl'
    end
  end

  def view
    @story = Story.find(params[:id])
    Rails.logger.info("Constructing story #{@story.thread_url}")
  end

  private

  def submit_story_params
    params.require(:story).permit(:thread_url, :generate_epub)
  end

  def create_or_update_story(params)
    thread_url = params[:thread_url]
    story = Story.find_by(thread_url: thread_url) || Story.new(thread_url: thread_url)
    story.download_complete = false
    story.refresh_story = true
    story.generate_epub = true if params[:generate_epub] == '1'
    story.save
  end

  def valid_url?(url)
    uri = URI.parse(url)
    uri.is_a?(URI::HTTP) && !uri.host.nil?
  rescue URI::InvalidURIError
    false
  end

end
