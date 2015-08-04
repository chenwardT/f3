module PostsHelper
  def post_num(idx)
    if params[:page].present?
      ((params[:page].to_i - 1) * Post.default_per_page) + idx + 1
    else
      idx + 1
    end
  end

  def display_post_delete_text(post)
    deleted = "This post has been deleted by #{username_as_link(post.moderator)}"
    reason = "Reason: #{post.mod_reason}"
    br = tag(:br)

    content_tag(:sup, "#{deleted}#{br}#{reason}".html_safe).html_safe
  end

  def display_post_as_unapproved(post)
    unapproved = content_tag(:sup, "This post has not yet been approved.")
    br = tag(:br)

    "#{unapproved}#{br}".html_safe + post.body
  end

  def display_body_with_state(post)
    return display_post_delete_text(post) if post.deleted?
    return display_post_as_unapproved(post) if post.unapproved?
    post.body
  end
end
