class CreateViewsAndAddViewsCountCols < ActiveRecord::Migration
  def change
    create_table :views do |t|
      t.integer 'user_id'
      t.integer 'viewable_id'
      t.timestamps null: false
      t.integer 'count', default: 0
      t.string 'viewable_type'
      t.datetime 'current_viewed_at'
      t.datetime 'past_viewed_at'
    end

    add_foreign_key :views, :users
  end
end
