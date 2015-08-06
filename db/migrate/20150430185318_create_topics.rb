class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.integer :category_id
      t.string :title
      t.string :slug
      t.boolean :locked, null: false, default: false
      t.boolean :hidden, null: false, default: false
      t.boolean :pinned, null: false, default: false
      t.integer :views_count

      t.timestamps null: false
    end
  end
end
