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

  def lock?
    if user
      if user.able_to?(:lock_or_unlock_any_topic, record.forum)
        true
      else
        record.author == user && user.able_to?(:lock_or_unlock_own_topic, record.forum)
      end
    end
  end

  def unlock?
    lock?
  end

  def copy?
    if user
      if user.able_to?(:copy_or_move_any_topic, record.forum)
        true
      else
        record.author == user && user.able_to?(:copy_or_move_own_topic, record.forum)
      end
    end
  end

  def move?
    copy?
  end
end