class Topic < ActiveRecord::Base
  include Viewable

  belongs_to :forum
  belongs_to :user
  alias_attribute :author, :user

  has_many :posts, dependent: :destroy

  validates :user, presence: true

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

  def visible_posts
    ordered_posts.where(state: 'visible')
  end

  def visible_posts_for_user(user)
    ordered_posts.where("state = ? OR (user_id = ? AND state IN ('deleted', 'unapproved'))",
                        :visible, user.id)
  end

  def num_pages
    (posts.count / POSTS_PER_PAGE.to_f).ceil.to_i
  end

  def num_unapproved_posts
    posts.where(state: 'unapproved').count
  end
end
