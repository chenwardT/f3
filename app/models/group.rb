class Group < ActiveRecord::Base
  validates :name, :presence => true

  has_many :user_groups
  has_many :users, through: :user_groups
  has_many :forum_permissions

  def to_s
    name
  end

  def user_count
    users.count
  end
end
