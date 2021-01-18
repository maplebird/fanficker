class CreateStories < ActiveRecord::Migration[6.0]
  def change
    create_table :stories do |t|
      t.string :title
      t.string :author
      t.string :url
      t.integer :chapters
      t.string :location
      t.timestamps
    end
  end
end
