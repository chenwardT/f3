class CreateForums < ActiveRecord::Migration
  def change
    create_table :forums do |t|
      t.string :title
      t.string :slug
      t.integer :view_count
      t.integer :category_id
      t.boolean :locked, null: false, default: false
      t.boolean :hidden, null: false, default: false

      t.timestamps null: false
    end
  end
end
