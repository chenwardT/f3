class ForumPermission < ActiveRecord::Base
  # TODO: Try indexing these FKs.
  belongs_to :forum
  belongs_to :group

  def to_s
    "#{forum}: #{group}"
  end

  # Follow inheritance tree until non-inheriting ForumPermission instance is found.
  # If the last (root) ForumPermission instance has +inherit+ set, then use the Group's
  # permissions.
  def effective_permissions
    source = self

    while source.inherit && source.forum.parent
      source = source.forum.parent.forum_permissions.find_by(group: group)
    end

    source = group if source.inherit

    source
  end
end
