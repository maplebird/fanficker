class CreateChapters < ActiveRecord::Migration[6.0]
  def change
    create_table :chapters do |t|
      t.string :thread_url
      t.string :title
      t.integer :threadmark
      t.text :body
    end

    add_index(:chapters, [:id, :threadmark])
    add_index(:chapters, :thread_url)
  end
end
