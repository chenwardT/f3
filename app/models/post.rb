class Post < ActiveRecord::Base
  belongs_to :user
  belongs_to :topic
  belongs_to :moderator, class_name: 'User'

  after_create :update_topic_last_post_at

  paginates_per POSTS_PER_PAGE

  # Note: update_all does not trigger callbacks/validations.
  def self.soft_delete(ids, user, reason=nil)
    self.where(id: ids).update_all(state: 'deleted', moderator_id: user, mod_reason: reason)
  end

  def self.undelete(ids, user)
    self.where(id: ids).update_all(state: 'visible', moderator_id: user, mod_reason: nil)
  end

  def self.approve(ids, user)
    self.where(id: ids).update_all(state: 'visible', moderator_id: user)
  end

  def self.unapprove(ids, user)
    self.where(id: ids).update_all(state: 'unapproved', moderator_id: user)
  end

  def deleted?
    state == 'deleted'
  end

  def unapproved?
    state == 'unapproved'
  end

  protected

  def update_topic_last_post_at
    topic.update_column(:last_post_at, created_at)
  end
end
