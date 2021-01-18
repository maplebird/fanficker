class StoryController < ApplicationController
  def index
    @stories = Story.all
  end

  def new
    @story = Story.new
  end

  def create
    @story = Story.create_or_find_by(submit_story_params)

    download_story

    if @story.save
      redirect_to '/index'
    else
      render 'new'
    end
  end

  private

  def submit_story_params
    params.require(:story).permit(:thread_url)
  end

  def download_story
    :thread_url
  end

end
