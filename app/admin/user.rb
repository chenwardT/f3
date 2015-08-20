ActiveAdmin.register User do
  index do
    id_column
    column :username
    column :email
    actions
  end

  preserve_default_filters!
  remove_filter :topics
  remove_filter :posts
  remove_filter :user_groups
  remove_filter :encrypted_password
  remove_filter :reset_password_token
  remove_filter :remember_created_at
end
