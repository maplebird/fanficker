class StoriesController < ApplicationController
  def index
    @stories = Story.all
  end

  def new
    @story = Story.new
  end

  def create
    params = submit_story_params
    return unless valid_url?(params[:thread_url])

    @story = Story.new(params)

    if @story.save
      Rails.logger.info("[NewStory] Submitted with URL: #{params[:thread_url]}")
      redirect_to '/index'
    else
      Rails.logger.info("[NewStory] Invalid URL: #{params[:thread_url]}")
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
