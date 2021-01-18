class Story < ApplicationRecord
  validates :thread_url, uniqueness: true

  after_create :download_story

  def download_story
    DownloadStoryJob.perform_now(thread_url)
  end

end
