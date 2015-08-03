class TopicPolicy < ApplicationPolicy
  def moderate?
    user && user.admin?
  end
end