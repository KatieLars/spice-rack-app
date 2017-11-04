class DeleteUserIdColumnInFlavors < ActiveRecord::Migration[5.1]
  def change
    remove_column :flavors, :user_id
  end
end
