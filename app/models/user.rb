class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable


  has_many :topics
  has_many :posts
  has_many :user_groups
  has_many :groups, through: :user_groups

  def to_s
    username
  end
end
