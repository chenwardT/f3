class CreateForumPermissions < ActiveRecord::Migration
  def change
    create_table :forum_permissions do |t|

      t.timestamps null: false

      # Relations
      t.boolean :inherit, default: true, null: false
      t.belongs_to :group
      t.belongs_to :forum

      # View content
      t.boolean :view_forum, default: true, null: false
      t.boolean :view_topic, default: true, null: false

      # Owned content
      t.boolean :preapproved_posts, default: true, null: false
      t.boolean :create_topic, default: true, null: false
      t.boolean :create_post, default: true, null: false
      t.boolean :edit_own_post, default: true, null: false
      t.boolean :soft_delete_own_post, default: false, null: false
      t.boolean :hard_delete_own_post, default: false, null: false
      t.boolean :lock_or_unlock_own_topic, default: false, null: false
      t.boolean :copy_or_move_own_topic, default: false, null: false

      # Any content
      t.boolean :edit_any_post, default: false, null: false
      t.boolean :soft_delete_any_post, default: false, null: false
      t.boolean :hard_delete_any_post, default: false, null: false
      t.boolean :lock_or_unlock_any_topic, default: false, null: false
      t.boolean :copy_or_move_any_topic, default: false, null: false
      # move/copy/merge/stick topics and posts
      t.boolean :manage_any_content, default: false, null: false
    end
  end
end
