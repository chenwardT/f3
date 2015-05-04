class Topic < ActiveRecord::Base
  belongs_to :forum
  belongs_to :user

  has_many :posts

  def reply_count
    posts.count - 1
  end

  def last_post
    posts.order(created_at: :asc).last
  end
end
