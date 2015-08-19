class ForumPermission < ActiveRecord::Base
  belongs_to :forum
  belongs_to :group
end
