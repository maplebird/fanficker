class CreateChapters < ActiveRecord::Migration[6.0]
  def change
    create_table :chapters do |t|
      t.string :thread_url
      t.integer :threadmark
      t.text :body
    end

    add_foreign_key(:chapters, :stories, column: :thread_url, on_delete: :cascade)

    add_index(:chapters, :id)
    add_index(:chapters, :thread_url)
  end
end
