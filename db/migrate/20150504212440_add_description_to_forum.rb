class AddDescriptionToForum < ActiveRecord::Migration
  def change
    add_column :forums, :description, :string
  end
end
