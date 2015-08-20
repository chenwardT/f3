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

  permit_params :name, :description, :create_forum, :view_forum, :view_topic, :preapproved_posts,
                :create_post, :edit_own_post, :soft_delete_own_post, :hard_delete_own_post,
                :create_topic, :lock_or_unlock_own_topic, :copy_or_move_own_topic, :edit_any_post,
                :soft_delete_any_post, :hard_delete_any_post, :lock_or_unlock_any_topic,
                :copy_or_move_any_topic, :moderate_any_forum, :admin
end
