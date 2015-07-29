class CascadeDeleteForPostsOfTopic < ActiveRecord::Migration
  def change
    remove_foreign_key :posts, :topics
    add_foreign_key :posts, :topics, on_delete: :cascade
  end
end
