class Chapter < ApplicationRecord
  belongs_to :story, foreign_key: :thread_url
end
