class AddAdminFieldToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :admin, :boolean, default: false, null: false
  end
end
