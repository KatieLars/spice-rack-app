class CreateRecipeSpiceFlavorsJoinTable < ActiveRecord::Migration[5.1]
  def change
    create_table :recipe_spice_flavors do |t|
      t.integer :recipe_id
      t.integer :flavor_id
      t.integer :spice_id
      t.integer :user_id
    end
  end
end
