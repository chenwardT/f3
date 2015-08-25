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

  permit_params :email, :username, :password, :birthday, :time_zone, :country, :quote, :website,
                :bio, :signature, group_ids: []

  form do |f|
    f.inputs "Profile" do
      f.input :email
      f.input :username
      f.input :password if f.object.new_record?
      f.input :birthday
      f.input :time_zone
      f.input :country
      f.input :quote
      f.input :website
      f.input :bio
      f.input :signature
    end

    f.inputs "User Groups" do
      f.input :groups, as: :check_boxes
    end

    f.actions
  end

  controller do
    def update
      @user = User.find(params[:id])

      begin
        ActiveRecord::Base.transaction do
          @user.update_attributes!(permitted_params[:user])

          if permitted_params[:user][:group_ids]
            @user.groups = []

            permitted_params[:user][:group_ids].each do |id|
              @user.groups << Group.find(id) if id != ""
            end
          end
        end
      rescue ActiveRecord::RecordInvalid
        # TODO: Cleanup
        flash[:danger] = @user.errors.full_messages
        redirect_to edit_admin_user_path(@user) and return
      end

      flash[:notice] = 'User was successfully updated.'
      redirect_to admin_user_path(@user)
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
