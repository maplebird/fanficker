class AddStoryStatusField < ActiveRecord::Migration[6.0]
  def change
    add_column(:stories, :download_complete, :boolean)
  end
end
