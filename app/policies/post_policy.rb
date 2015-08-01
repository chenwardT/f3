class PostPolicy < ApplicationPolicy
  def soft_delete?
    user.groups.include?(Group.find_by(name: 'admin'))
  end
end