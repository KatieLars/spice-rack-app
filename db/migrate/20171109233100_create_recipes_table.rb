class CreateRecipesTable < ActiveRecord::Migration[5.1]
  def change
    create_table :recipes do |t|
      t.string :name
      t.string :url
      t.integer :user_id
    end
  end
end