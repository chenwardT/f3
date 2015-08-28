class Group < ActiveRecord::Base
  validates :name, :presence => true

  has_many :user_groups
  has_many :users, through: :user_groups
  has_many :forum_permissions

  after_create :create_forum_permissions
  before_destroy :destroy_forum_permissions

  def to_s
    name
  end

  def user_count
    users.count
  end

  private

  def create_forum_permissions
    ActiveRecord::Base.transaction do
      Forum.all.each do |forum|
        ForumPermission.create(forum: forum, group: self)
      end
    end
  end

  def destroy_forum_permissions
    ForumPermission.where(group: self).destroy_all
  end
end
