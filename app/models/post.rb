class Post < ActiveRecord::Base
  belongs_to :user
  belongs_to :topic
  belongs_to :moderator, class_name: 'User'

  # TODO: Consider removing this requirement for user deletion use cases
  validates :user_id, presence: true
  validates :topic_id, presence: true
  # TODO: Set via site config directive
  validates :body, length: { minimum: 10 }

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

  # Merges the bodies of 2 or more posts given by +sources+ into a single post, specified by
  # +destination+. This deletes all +sources+ posts except +destination+. The body of the
  # destination will be set to +body+ and the owner will be set to +author+. The user who
  # performed the merge is specified by +user+. An optional +reason+ may be passed to explain
  # the merge.
  def self.merge(sources, destination, author, body, user, reason=nil)
    source_posts = Post.where(id: sources).where.not(id: destination)
    merge_into = Post.find(destination)
    author_user = User.find(author)

    ActiveRecord::Base.transaction do
      merge_into.update_attributes(body: body, user: author_user, moderator: user, mod_reason: reason)
      source_posts.delete_all
    end
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
