class CreateStories < ActiveRecord::Migration[6.0]
  def change
    create_table :stories do |t|
      t.string :thread_url
      t.string :title
      t.string :author
      t.string :author_profile
      t.integer :chapter_count
      t.text :description
      t.timestamps
    end

    add_index(:stories, :thread_url, unique: true)
  end
end
