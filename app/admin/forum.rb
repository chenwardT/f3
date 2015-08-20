ActiveAdmin.register Forum do
  index do
    id_column
    column :title
    column :description
    column :breadcrumb
    actions
  end

  config.filters = false
end
