class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  scope :newest, -> { order(created_at: :asc).pluck(:username).last }

  has_many :topics
  has_many :posts
  has_many :user_groups
  has_many :groups, through: :user_groups

  def to_s
    username
  end

  def profile_fields
    fields = []

    fields << :country if country
    fields << :bio if bio
    fields << :quote if quote
    fields << :website if website
    fields << :signature if signature

    fields
  end

  # Performs a pessimistic authorization check for this user given an +action+ and an
  # optionally specified +resource+.
  #
  # If a +resource+ is given, then the resource's group-specific permissions are checked against
  # the user's groups.
  # If a +resource+ is not given, then the user's groups are checked for permissions.
  def able_to?(action, forum)
    applicable_permissions = ForumPermission.where(forum: forum, group: groups)

    applicable_permissions.each do |permissions|
      return true if permissions.effective_permissions[action.to_sym]
    end

    false
  end

  def is_admin?
    groups.each { |group| return true if group.admin }

    false
  end
end
