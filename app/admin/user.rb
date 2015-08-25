ActiveAdmin.register User do
  index do
    id_column
    column :username
    column :email
    actions
  end

  show :title => proc {|user| user.username} do
    attributes_table do
      row :id
      row :username
      row :email
      row :reset_password_sent_at
      row :sign_in_count
      row :current_sign_in_at
      row :last_sign_in_at
      row :created_at
      row :updated_at
      row :birthday
      row :time_zone
      row :country
      row :quote
      row :website
      row :bio
      row :signature
    end

    panel 'Group Membership' do
      table_for user.groups do
        column 'Name' do |group|
          group.name
        end
        column 'Description' do |group|
          group.description
        end
        column do |group|
          span do
            link_to 'View', admin_group_path(group.id)
          end
          span do
            link_to 'Edit', edit_admin_group_path(group.id)
          end
        end
      end
    end
  end
  preserve_default_filters!
  remove_filter :topics
  remove_filter :posts
  remove_filter :user_groups
  remove_filter :encrypted_password
  remove_filter :reset_password_token
  remove_filter :remember_created_at
end
