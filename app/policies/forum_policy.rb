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

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.select { |forum| user.able_to?(:view_forum, forum) }
    end
  end
end