class Forum < ActiveRecord::Base
  include Viewable

  belongs_to :forum

  has_many :forums
  has_many :topics
  has_many :forum_permissions

  scope :tree_for, ->(instance) { where("#{table_name}.id IN (#{tree_sql_for(instance)})").
                                  order("#{table_name}.id") }

  def to_s
    title
  end

  def parent
    forum
  end

  def breadcrumb
    trail = [self.title]

    parent = self.forum

    until parent.nil?
      trail << parent.title
      parent = parent.forum
    end

    trail.reverse.join(" > ")
  end

  # TODO: Rename
  def topic_count
    topics.count
  end

  def self_and_desc_topic_count
    Topic.where(forum: self.self_and_descendents).count
  end

  def post_count
    Post.where(topic: topics).count
  end

  def self_and_desc_post_count
    Post.joins(topic: :forum).where('forums.id' => self.self_and_descendents).count
  end

  def last_topic
    Topic.where(forum_id: self.self_and_descendents)
        .order(last_post_at: :desc)
        .first
  end

  def last_post_in_last_topic
    last_topic.posts.order(created_at: :desc).first
  end

  def self_and_descendents
    self.class.tree_for(self)
  end

  def self.tree_sql_for(instance)
    tree_sql = <<-SQL
      WITH RECURSIVE search_tree(id, path) AS (
          SELECT id, ARRAY[id]
          FROM #{table_name}
          WHERE id = #{instance.id}
        UNION ALL
          SELECT #{table_name}.id, path || #{table_name}.id
          FROM search_tree
          JOIN #{table_name} ON #{table_name}.forum_id = search_tree.id
          WHERE NOT #{table_name}.id = ANY(path)
        )
        SELECT id FROM search_tree ORDER BY path
    SQL
  end
end
