class Post < ActiveRecord::Base
  belongs_to :user
  belongs_to :topic
  belongs_to :moderator, class_name: 'User'

  after_create :update_topic_last_post_at

  paginates_per POSTS_PER_PAGE

  def soft_delete(user, reason)
    if reason
      update_attributes(moderator: user, state: 'soft_delete', mod_reason: reason)
    else
      update_attributes(moderator: user, state: 'soft_delete')
    end
  end

  def deleted?
    state == 'soft_delete'
  end

  protected

  def update_topic_last_post_at
    topic.update_column(:last_post_at, created_at)
  end
end
