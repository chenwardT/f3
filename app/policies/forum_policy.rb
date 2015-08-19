class ForumPolicy < ApplicationPolicy
  def show?
    user && user.able_to?(:view_forum)
  end

  def moderate?
    user && user.able_to?(:moderate_any_forum)
  end

  def create?
    user && user.able_to?(:create_forum)
  end
end