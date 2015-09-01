class AddCopyOrMoveAnyPostPermission < ActiveRecord::Migration
  def change
    add_column :groups, :copy_or_move_any_post, :boolean, default: false, null: false
    add_column :forum_permissions, :copy_or_move_any_post, :boolean, default: false, null: false
  end
end
