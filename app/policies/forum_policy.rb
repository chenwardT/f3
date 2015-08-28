class ForumPolicy < ApplicationPolicy
  def show?
    user && user.able_to?(:view_forum, record)
  end

  def moderate?
    user && user.able_to?(:moderate_any_forum, record)
  end

  def create?
    user && user.able_to?(:create_forum, record.forum)
  end
end