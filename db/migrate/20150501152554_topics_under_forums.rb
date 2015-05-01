class TopicsUnderForums < ActiveRecord::Migration
  def change
    change_table :topics do |t|
      t.rename :category_id, :forum_id
    end
  end
end
