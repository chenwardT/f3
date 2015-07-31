class AddModerationFieldsToPost < ActiveRecord::Migration
  def change
      add_column :posts, :state, :string, default: 'visible'
      add_column :posts, :moderator_id, :integer
      add_column :posts, :mod_reason, :string
  end
end
