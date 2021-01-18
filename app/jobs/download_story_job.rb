class DownloadStoryJob < ApplicationJob
  queue_as :default

  def perform(params)

    puts "Submitting story with parameters: "
    puts params
    # if params[:thread_url]
    #   Rails.console.log('Downloading story ', params[:thread_url])
    # end
  end
end
