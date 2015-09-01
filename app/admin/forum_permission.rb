ActiveAdmin.register ForumPermission do
  index do
    id_column
    column :forum
    column :forum_id
    column :group
    column :group_id
    column :inherit
    column :effective_permissions
    actions
  end

  config.sort_order = 'forum_id_asc'

  filter :forum
  filter :group
  filter :inherit

  show :title => proc {|fp| fp} do
    attributes_table do
      row :id
      row :forum
      row :group
      row ("Inherit from parent") { |fp| fp.inherit }
      row :created_at
      row :updated_at
    end

    panel "Forum Permissions" do
      attributes_table_for forum_permission do
        row :view_forum
        row :view_topic
        row :create_topic
        row :create_post
        row :preapproved_posts
        row :edit_own_post
        row :soft_delete_own_post
        row :hard_delete_own_post
        row :lock_or_unlock_own_topic
        row :copy_or_move_own_topic
      end
    end

    panel "Moderator Permissions" do
      attributes_table_for forum_permission do
        row :edit_any_post
        row :soft_delete_any_post
        row :hard_delete_any_post
        row :copy_or_move_any_post
        row :lock_or_unlock_any_topic
        row :copy_or_move_any_topic
        row :manage_any_content
      end
    end
  end

  permit_params :inherit, :forum_id, :group_id, :view_forum, :view_topic, :preapproved_posts,
                :create_topic, :create_post, :edit_own_post, :soft_delete_own_post,
                :hard_delete_own_post, :lock_or_unlock_own_topic, :copy_or_move_own_topic,
                :edit_any_post, :soft_delete_any_post, :copy_or_move_any_post, :hard_delete_any_post,
                :lock_or_unlock_any_topic, :copy_or_move_any_topic, :manage_any_content

  form do |f|
    f.inputs "Permission Inheritance" do
      f.input :inherit, label: "Inherit from parent (permissions that are set here will be ignored)"
    end

    f.inputs "Forum Permissions" do
      f.input :view_forum
      f.input :view_topic
      f.input :create_topic
      f.input :create_post
      f.input :preapproved_posts
      f.input :edit_own_post
      f.input :soft_delete_own_post
      f.input :hard_delete_own_post
      f.input :lock_or_unlock_own_topic
      f.input :copy_or_move_own_topic
    end
    
    f.inputs "Moderator Permissions" do
      f.input :edit_any_post
      f.input :soft_delete_any_post
      f.input :hard_delete_any_post
      f.input :copy_or_move_any_post
      f.input :lock_or_unlock_any_topic
      f.input :copy_or_move_any_topic
      f.input :manage_any_content
    end

    f.actions
  end
end
