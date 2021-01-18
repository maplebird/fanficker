class PagesController < ApplicationController
  def index
    @stories = Story.all
  end

end
