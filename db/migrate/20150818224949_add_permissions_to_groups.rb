class AddPermissionsToGroups < ActiveRecord::Migration
  def change
    change_table :groups do |t|
      t.string :description

      t.boolean :create_forum, default: false, null: false

      t.boolean :view_forum, default: true, null: false
      t.boolean :view_topic, default: true, null: false

      # Owned content
      t.boolean :preapproved_posts, default: true, null: false
      t.boolean :create_post, default: true, null: false
      t.boolean :edit_own_post, default: true, null: false
      t.boolean :soft_delete_own_post, default: false, null: false
      t.boolean :hard_delete_own_post, default: false, null: false

      t.boolean :create_topic, default: true, null: false
      t.boolean :lock_or_unlock_own_topic, default: false, null: false
      t.boolean :copy_or_move_own_topic, default: false, null: false

      # Any content
      t.boolean :edit_any_post, default: false, null: false
      t.boolean :soft_delete_any_post, default: false, null: false
      t.boolean :hard_delete_any_post, default: false, null: false
      t.boolean :lock_or_unlock_any_topic, default: false, null: false
      t.boolean :copy_or_move_any_topic, default: false, null: false
      t.boolean :moderate_any_forum, default: false, null: false
    end
  end
end
