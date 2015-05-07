class AddProfileFieldsToUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.date :birthday
      t.string :time_zone, :country, :quote, :website
      t.text :bio, :signature
    end
  end
end
