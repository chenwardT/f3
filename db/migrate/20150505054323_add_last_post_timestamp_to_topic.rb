class AddLastPostTimestampToTopic < ActiveRecord::Migration
  def change
    add_column :topics, :last_post_at, :datetime
  end
end
