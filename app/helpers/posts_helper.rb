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

    "#{deleted}#{br}#{reason}".html_safe
  end
end
