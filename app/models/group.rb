class Group < ActiveRecord::Base
  validates :name, :presence => true

  has_many :user_groups
  has_many :users, through: :user_groups

  def to_s
    name
  end
end
