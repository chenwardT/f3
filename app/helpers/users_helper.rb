module UsersHelper
  def username_as_link(user)
    content_tag(:a, "#{user.username}", href: user_path(user))
  end
end
