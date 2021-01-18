class StoriesController < ApplicationController
  def index
    @stories = Story.all
  end

  def new
    @story = Story.new
  end

  def create
    params = submit_story_params.merge({ refresh_story: true })

    @story = Story.find_or_create_by(params)
    Rails.logger.info("[NewStory] Submitted with URL: #{params[:thread_url]}")

    if @story.save
      redirect_to '/index'
    else
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

  def valid_url?(url)
    uri = URI.parse(url)
    uri.is_a?(URI::HTTP) && !uri.host.nil?
  rescue URI::InvalidURIError
    false
  end

end
