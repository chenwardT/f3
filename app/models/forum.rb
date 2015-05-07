class Forum < ActiveRecord::Base
  belongs_to :forum

  has_many :forums
  has_many :topics

  def to_s
    title
  end

  def topic_count
    topics.count
  end

  def post_count
    topics.map{|topic| topic.posts.count}.reduce(:+)
  end

  def last_post
    # topics.all
  end
end
