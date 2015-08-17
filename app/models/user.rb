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

  def admin?
    groups.include?(Group.find_by(name: 'admin'))
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
end
