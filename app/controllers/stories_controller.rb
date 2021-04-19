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
    params.require(:story).permit(:thread_url)
  end

  def create_or_update_story(params)
    story = Story.find_by(params) || Story.new(params)
    story.download_complete = false
    story.refresh_story = true
    story.save
  end

  def valid_url?(url)
    uri = URI.parse(url)
    uri.is_a?(URI::HTTP) && !uri.host.nil?
  rescue URI::InvalidURIError
    false
  end

end
