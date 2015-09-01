class TopicPolicy < ApplicationPolicy
  def show?
    user && user.able_to?(:view_topic, record.forum)
  end

  def new?
    create?
  end

  def create?
    user && user.able_to?(:create_topic, record.forum)
  end

  def moderate?
    user && user.able_to?(:moderate_any_forum, record.forum)
  end
end