class CreateEpubPath < ActiveRecord::Migration[6.0]
  def change
    add_column(:stories, :epub, :string)
  end
end
