class PostPolicy < ApplicationPolicy
  def create?
    user && user.able_to?(:create_post, record.forum)
  end

  def soft_delete?
    if user
      if user.able_to?(:soft_delete_any_post, record.forum)
        true
      else
        record.author == user && user.able_to?(:soft_delete_own_post, record.forum)
      end
    end
  end

  def hard_delete?
    if user
      if user.able_to?(:hard_delete_any_post, record.forum)
        true
      else
        record.author == user && user.able_to?(:hard_delete_own_post, record.forum)
      end
    end
  end

  # TODO: Make new permission or rename +moderate_any_forum+.

  def approve?
    user && user.able_to?(:moderate_any_forum, record.forum)
  end

  def merge?
    user && user.able_to?(:moderate_any_forum, record.forum)
  end

  def copy?
    user && ( user.able_to?(:moderate_any_forum, record.forum) ||
              user.able_to?(:copy_or_move_any_post, record.forum) )
  end

  def move?
    copy?
  end
end