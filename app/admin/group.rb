ActiveAdmin.register Group do
  index do
    id_column
    column :name
    column :description
    column :user_count
    actions do |group|
      item 'Show Users', admin_users_path('q[user_groups_group_id_eq]' => group.id)
    end
  end

  config.sort_order = 'name_asc'
  config.filters = false

  show :title => proc {|group| group.name + " (id: #{group.id})"} do
    attributes_table do
      row :name
      row :description
      row :created_at
      row :updated_at
    end

    panel "Moderator Permissions" do
      attributes_table_for group do
        row :edit_any_post
        row :soft_delete_any_post
        row :hard_delete_any_post
        row :copy_or_move_any_post
        row :lock_or_unlock_any_topic
        row :copy_or_move_any_topic
        row :moderate_any_forum
      end
    end

    panel "Create Permissions" do
      attributes_table_for group do
        row :create_forum
      end
    end

    panel "Forum Permissions" do
      attributes_table_for group do
        row :preapproved_posts
      end
    end

    panel "Forum Viewing Permissions" do
      attributes_table_for group do
        row :view_forum
        row :view_topic
      end
    end

    panel "Post / Topic Permissions" do
      attributes_table_for group do
        row :create_post
        row :create_topic
        row :edit_own_post
        row :soft_delete_own_post
        row :hard_delete_own_post
        row :lock_or_unlock_own_topic
        row :copy_or_move_own_topic
      end
    end

    panel "Administrator Permissions" do
      attributes_table_for group do
        row :admin
      end
    end
  end

  form do |f|
    f.inputs "Group Details" do
      f.input :name
      f.input :description
    end

    f.inputs "Moderator Permissions" do
      f.input :edit_any_post
      f.input :soft_delete_any_post
      f.input :hard_delete_any_post
      f.input :copy_or_move_any_post
      f.input :lock_or_unlock_any_topic
      f.input :copy_or_move_any_topic
      f.input :moderate_any_forum
    end

    f.inputs "Create Permissions" do
        f.input :create_forum
    end

    f.inputs "Forum Permissions" do
        f.input :preapproved_posts
    end

    f.inputs "Forum Viewing Permissions" do
        f.input :view_forum
        f.input :view_topic
    end

    f.inputs "Post / Topic Permissions" do
        f.input :create_post
        f.input :create_topic
        f.input :edit_own_post
        f.input :soft_delete_own_post
        f.input :hard_delete_own_post
        f.input :lock_or_unlock_own_topic
        f.input :copy_or_move_own_topic
    end

    f.inputs "Administrator Permissions" do
        f.input :admin
    end

    f.actions
  end

  permit_params :name, :description, :create_forum, :view_forum, :view_topic, :preapproved_posts,
                :create_post, :edit_own_post, :soft_delete_own_post, :hard_delete_own_post,
                :create_topic, :lock_or_unlock_own_topic, :copy_or_move_own_topic, :edit_any_post,
                :soft_delete_any_post, :hard_delete_any_post, :copy_or_move_any_post,
                :lock_or_unlock_any_topic, :copy_or_move_any_topic, :moderate_any_forum, :admin
end
