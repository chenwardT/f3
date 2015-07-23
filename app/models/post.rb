class Post < ActiveRecord::Base
  belongs_to :user
  belongs_to :topic

  after_create :update_topic_last_post_at

  paginates_per POSTS_PER_PAGE

  protected

  def update_topic_last_post_at
    topic.update_column(:last_post_at, created_at)
  end
end
