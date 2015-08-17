class AddStateToTopic < ActiveRecord::Migration
  def change
    add_column :topics, :state, :string, default: 'visible'
  end
end
