class CreateSpicesTable < ActiveRecord::Migration[5.1]
  def change
    create_table :spices do |t|
      t.string :name
      t.integer :flavor_id
      t.integer :user_id
    end
  end
end
