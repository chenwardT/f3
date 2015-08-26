ActiveAdmin.register Forum do
  index do
    id_column
    column :title
    column :description
    column :breadcrumb
    actions
  end

  show :title => proc {|forum| forum.title} do
    attributes_table do
      row :id
      row("Parent Forum") { |forum| forum.forum }
      row :title
      row :slug
      row :description
      row :views_count
      row :locked
      row :hidden
      row :created_at
      row :updated_at
    end
  end

  permit_params :title, :description, :forum_id, :locked, :hidden

  form do |f|
    f.inputs "Forum" do
      f.input :title
      f.input :description
      f.input :forum, label: "Parent Forum"
      f.input :locked
      f.input :hidden
    end

    f.actions
  end

  config.filters = false
end
