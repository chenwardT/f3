class ForumPermission < ActiveRecord::Base
  belongs_to :forum
  belongs_to :group

  def to_s
    "#{forum}: #{group}"
  end

  def effective_permissions
    source = self

    while source.inherit
      # "if source.forum.forum" only needed if root doesn't specify inherit = false
      source = source.forum.parent.forum_permissions.find_by(group: group) if source.forum.parent
    end

    source
  end
end
