class TopicPolicy < ApplicationPolicy
  def view?
    user && user.able_to?(:view_topic)
  end

  def new?
    create?
  end

  def create?
    user && user.able_to?(:create_topic)
  end
end