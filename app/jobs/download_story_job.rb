class DownloadStoryJob < ApplicationJob
  queue_as :default

  def perform(*args)
    :thread_url



  end
end
