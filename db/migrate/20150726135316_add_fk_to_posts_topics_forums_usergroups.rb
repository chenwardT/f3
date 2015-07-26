class AddFkToPostsTopicsForumsUsergroups < ActiveRecord::Migration
  def change
    add_foreign_key :forums, :forums
    add_foreign_key :posts, :users
    add_foreign_key :posts, :topics
    add_foreign_key :topics, :forums
    add_foreign_key :topics, :users
    add_foreign_key :user_groups, :users
    add_foreign_key :user_groups, :groups
  end
end
