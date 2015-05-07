class Topic < ActiveRecord::Base
  belongs_to :forum
  belongs_to :user

  has_many :posts

  def to_s
    title
  end

  def reply_count
    posts.count - 1
  end

  def last_post
    posts.order(created_at: :asc).last
  end

  def ordered_posts
    posts.order(created_at: :asc)
  end
end
