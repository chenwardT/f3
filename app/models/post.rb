require 'uri'

# TODO: Set default post state via site config (currently using migration)
class Post < ActiveRecord::Base
  include PaperTrailable

  belongs_to :user
  alias_attribute :author, :user
  belongs_to :topic
  delegate :forum, to: :topic
  belongs_to :moderator, class_name: 'User'   # TODO: OK to store only the last moderator?

  # TODO: Consider removing this requirement for user deletion use cases
  validates :user_id, presence: true
  validates :topic_id, presence: true
  # TODO: Set via site config directive
  validates :body, length: { minimum: 10 }

  after_create :update_topic_last_post_at

  paginates_per POSTS_PER_PAGE

  def self.soft_delete(ids, user, reason=nil)
    where(id: ids).each do |post|
      post.set_event(__method__)
      post.update_attributes(state: 'deleted', moderator: user, mod_reason: reason)
    end
  end

  def self.undelete(ids, user)
    where(id: ids).each do |post|
      post.set_event(__method__)
      post.update_attributes(state: 'visible', moderator: user, mod_reason: nil)
    end
  end

  def self.approve(ids, user)
    where(id: ids).each do |post|
      post.set_event(__method__)
      post.update_attributes(state: 'visible', moderator: user)
    end
  end

  def self.unapprove(ids, user)
    where(id: ids).each do |post|
      post.set_event(__method__)
      post.update_attributes(state: 'unapproved', moderator: user)
    end
  end

  # Merges the bodies of 2 or more posts given by +sources+ IDs into a single post, specified by
  # +destination+ ID. This deletes all +sources+ posts except +destination+. The body of the
  # destination will be set to +body+ and the owner will be set to +author+. The user who
  # performed the merge is specified by +user+. An optional +reason+ may be passed to explain
  # the merge.
  def self.merge(sources, destination, author, body, user, reason=nil)
    source_posts = Post.where(id: sources).where.not(id: destination)
    merge_into = Post.find(destination)
    author_user = User.find(author)

    ActiveRecord::Base.transaction do
      merge_into.set_event(__method__)
      merge_into.update_attributes(body: body, user: author_user, moderator: user, mod_reason: reason)
      source_posts.destroy_all
    end
  end

  # Move the posts specified by +post_ids+ to a new or existing topic.
  #
  # If +create_topic+ is true, a new topic is created in the forum given by +destination_forum_id+
  # with a title given by +new_topic_title+ and owner of +new_topic_author+.
  # Otherwise a path to an existing topic, given by +dest_topic_url+, is used to copy the posts into.
  #
  # Returns the destination topic.
  def self.move(create_topic, new_topic_author, post_ids, destination_forum_id=nil,
      new_topic_title=nil, dest_topic_url=nil)
    source_posts = Post.where(id: post_ids)
    source_topics = source_posts.map{|p| p.topic}.uniq

    if create_topic
      new_topic = self.move_to_new_topic(source_posts, source_topics, destination_forum_id,
                                         new_topic_author, new_topic_title)
    else
      dest_topic_url = 'http://' + dest_topic_url unless dest_topic_url.match(/^http:\/\//)
      path = URI.parse(dest_topic_url).path
      reverse_lookup = Rails.application.routes.recognize_path(path)

      destination_topic = self.move_to_existing_topic(source_posts, source_topics, reverse_lookup)
    end

    new_topic || destination_topic
  end

  # Copy the posts specified by +post_ids+ to a new or existing topic.
  #
  # If +create_topic+ is true, a new topic is created in the forum given by +destination_forum_id+
  # with a title given by +new_topic_title+ and owner of +new_topic_author+.
  # Otherwise a path to an existing topic, given by +dest_topic_url+, is used to copy the posts into.
  #
  # Returns the destination topic.
  def self.copy(create_topic, new_topic_author, post_ids, destination_forum_id=nil,
      new_topic_title=nil, dest_topic_url=nil)
    source_posts = Post.where(id: post_ids)

    if create_topic
      new_topic = self.copy_to_new_topic(source_posts, new_topic_author, new_topic_title,
      destination_forum_id)
    else
      dest_topic_url = 'http://' + dest_topic_url unless dest_topic_url.match(/^http:\/\//)
      path = URI.parse(dest_topic_url).path
      reverse_lookup = Rails.application.routes.recognize_path(path)

      destination_topic = self.copy_to_existing_topic(source_posts, reverse_lookup)
    end

    new_topic || destination_topic
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

  private

  def self.move_to_new_topic(source_posts, source_topics, destination_forum_id,
      new_topic_author, new_topic_title)
    forum = Forum.find(destination_forum_id)
    new_topic = nil

    ActiveRecord::Base.transaction do
      new_topic = forum.topics.create(user: new_topic_author, title: new_topic_title)

      source_posts.each do |post|
        post.set_event(__method__)
        post.update_attributes(topic: new_topic)
      end

      source_topics.each {|topic| topic.destroy if topic.posts.empty?}
    end

    new_topic
  end

  # TODO: Handle bad URL (e.g. does not point to a topic)
  def self.move_to_existing_topic(source_posts, source_topics, reverse_lookup)
    if reverse_lookup[:controller] == 'topics'
      destination_topic = nil

      ActiveRecord::Base.transaction do
        destination_topic = Topic.find(reverse_lookup[:id])

        source_posts.each do |post|
          post.set_event(__method__)
          post.update_attributes(topic: destination_topic)
        end

        source_topics.each {|topic| topic.destroy if topic.posts.empty?}
      end

      return destination_topic
    end
  end

  # Note: Created posts possess the same created_at and updated_at values as their originals.
  def self.copy_to_new_topic(source_posts, new_topic_author, new_topic_title, destination_forum_id)
    forum = Forum.find(destination_forum_id)
    new_topic = nil

    ActiveRecord::Base.transaction do
      new_topic = forum.topics.create(user: new_topic_author, title: new_topic_title)

      source_posts.each do |post|
        post_copy = post.dup
        post_copy.set_event(__method__)
        post_copy.update_attributes(topic: new_topic, created_at: post.created_at,
                                    updated_at: post.updated_at)
      end
    end

    new_topic
  end

  # Note: Created posts possess the same created_at and updated_at values as their originals.
  def self.copy_to_existing_topic(source_posts, reverse_lookup)
    destination_topic = nil

    if reverse_lookup[:controller] == 'topics'
      ActiveRecord::Base.transaction do
        destination_topic = Topic.find(reverse_lookup[:id])

        source_posts.each do |post|
          post_copy = post.dup
          post_copy.set_event(__method__)
          post_copy.update_attributes(topic: destination_topic, created_at: post.created_at,
                                      updated_at: post.updated_at)
        end
      end
    end

    destination_topic
  end

end
