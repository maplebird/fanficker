class CreateChapters < ActiveRecord::Migration[6.0]
  def change
    create_table :chapters do |t|
      t.integer :story_id
      t.string :title
      t.integer :threadmark
      t.text :body
    end

    add_index(:chapters, [:id, :threadmark])
    add_index(:chapters, :story_id)
  end
end
