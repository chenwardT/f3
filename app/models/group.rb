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

  def permissions_for(forum)
    forum_permissions.find_by(forum: forum)
  end

  # TODO: Refine when non-bool permissions added. Prefix permission fields w/string?
  def self.permission_fields
    boolean_fields
  end

  def self.boolean_fields
    column_types.map { |k, v| k if v.is_a? ActiveRecord::Type::Boolean }.compact
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
