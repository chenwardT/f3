require 'uri'

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

  # Move the posts specified by +post_ids+ to a new or existing topic.
  #
  # If +create_topic+ is true, a new topic is created in the forum given by +destination_forum_id+
  # with a title given by +new_topic_title+.
  # Otherwise a path to an existing topic, given by +url+, is used to copy the posts into.
  def self.move(create_topic, destination_forum_id=nil, new_topic_title=nil, url=nil, post_ids)
    if create_topic
      forum = Forum.find(destination_forum_id)

      ActiveRecord::Base.transaction do
        new_topic = forum.topics.create(user: current_user, title: new_topic_title)
        Post.where(id: post_ids).update_all(topic_id: new_topic.id)
      end
    else
      # TODO: Get path from +url+ that can be fed to recognize_path.
      # Below does not work when port is present.
      # url = 'http://' + url unless url.match(/^http:\/\//)
      # path = url.split(URI.parse(url).host).last
      # reverse_lookup = Rails.application.routes.recognize_path(path)
    end
  end

  # Copy the posts specified by +post_ids+ to a new or existing topic.
  #
  # If +create_topic+ is true, a new topic is created in the forum given by +destination_forum_id+
  # with a title given by +new_topic_title+.
  # Otherwise a path to an existing topic, given by +url+, is used to copy the posts into.
  def self.copy(create_topic, destination_forum_id=nil, new_topic_title=nil, url=nil, post_ids, user)
    if create_topic
      forum = Forum.find(destination_forum_id)

      ActiveRecord::Base.transaction do
        new_topic = forum.topics.create(user: user, title: new_topic_title)
        posts = Post.where(id: post_ids)

        posts.each do |post|
          post_copy = post.dup
          post_copy.topic = new_topic
          post_copy.save
        end
      end
    else
      # TODO: Get path from +url+ that can be fed to recognize_path.
      # Below does not work when port is present.
      # url = 'http://' + url unless url.match(/^http:\/\//)
      # path = url.split(URI.parse(url).host).last
      # reverse_lookup = Rails.application.routes.recognize_path(path)
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
