class Story < ApplicationRecord
  has_many :chapters

  before_validation :remove_trailing_slash

  validates :thread_url, uniqueness: true, presence: true

  attr_accessor :refresh_story
  after_commit :download_story, on: :create
  after_commit :download_story, on: :update, if: :refresh_story

  private

  def remove_trailing_slash
    thread_url.chomp('/')
  end

  def download_story
    DownloadStoryJob.perform_later(self)
  end

  def update_created
    self.created_at = Time.now
  end

  def update_timestamp
    self.updated_at = Time.now
  end

  def valid_thread_url
    uri = URI.parse(thread_url)
    errors.add(thread_url, "Must be HTTP/HTTPS.") unless uri.is_a?(URI::HTTP)
    errors.add(thread_url, "Hostname not present.") if uri.host.nil?
  rescue URI::InvalidURIError
    errors.add(thread_url, "Not a valid URL.")
  end
end
