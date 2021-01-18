class StoriesController < ApplicationController
  def index
    @stories = Story.all
  end

  def new
    @story = Story.new
  end

  def create
    if valid_url?(submit_story_params[:thread_url])
      Rails.logger.info("Submitted with URL: #{submit_story_params[:thread_url]}")
      @story = DownloadStoryJob.perform_now(submit_story_params)
      redirect_to '/index'
    else
      Rails.logger.info("Invalid URL: #{submit_story_params[:thread_url]}")
      redirect_to '/new?invalidurl'
    end
  end

  private

  def submit_story_params
    params.require(:story).permit(:thread_url)
  end

  def valid_url?(url)
    uri = URI.parse(url)
    uri.is_a?(URI::HTTP) && !uri.host.nil?
  rescue URI::InvalidURIError
    false
  end

end
