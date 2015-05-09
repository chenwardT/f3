class Forum < ActiveRecord::Base
  belongs_to :forum

  has_many :forums
  has_many :topics

  scope :tree_for, ->(instance) { where("#{table_name}.id IN (#{tree_sql_for(instance)})").
                                  order("#{table_name}.id") }

  def to_s
    title
  end

  # TODO: Rename
  def topic_count
    topics.count
  end

  def full_topic_count

  end

  def post_count
    topics.map{|topic| topic.posts.count}.reduce(:+)
  end

  def last_post

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
