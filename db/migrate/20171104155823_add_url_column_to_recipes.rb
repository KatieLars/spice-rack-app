class AddUrlColumnToRecipes < ActiveRecord::Migration[5.1]
  def change
    add_column :recipes, :url, :string
  end
end
