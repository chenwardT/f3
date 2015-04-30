class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.integer :user_id
      t.integer :topic_id
      t.text :body, null: false

      t.timestamps null: false
    end
  end
end
