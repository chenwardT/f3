class RemoveCategoriesAndForumBelongsToForum < ActiveRecord::Migration
  def change
    rename_column :forums, :category_id, :forum_id

    drop_table :categories
  end
end
