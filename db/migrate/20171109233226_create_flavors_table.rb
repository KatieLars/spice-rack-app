class CreateFlavorsTable < ActiveRecord::Migration[5.1]
  def change
    create_table :flavors do |t|
      t.string :name
    end
  end
end
