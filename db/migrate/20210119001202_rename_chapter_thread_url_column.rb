class RenameChapterThreadUrlColumn < ActiveRecord::Migration[6.0]
  def change
    rename_column(:chapters, :thread_url, :story_id)
  end
end
