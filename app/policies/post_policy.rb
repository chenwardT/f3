class PostPolicy < ApplicationPolicy

  def create?
    user && user.able_to?(:create_post)
  end

  def soft_delete?
    if user
      if user.able_to?(:soft_delete_any_post)
        true
      else
        record.user == user && user.able_to?(:soft_delete_own_post)
      end
    end
  end

  def hard_delete?
    if user
      if user.able_to?(:hard_delete_any_post)
        true
      else
        record.user == user && user.able_to?(:hard_delete_own_post)
      end
    end
  end

  def approve?
    user && user.able_to?(:moderate_any_forum)
  end

  def merge?
    user && user.able_to?(:moderate_any_forum)
  end

  def move?
    user && user.able_to?(:moderate_any_forum)
  end

  def copy?
    user && user.able_to?(:moderate_any_forum)
  end
end