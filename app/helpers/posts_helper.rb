module PostsHelper
  def post_num(idx)
    if params[:page].present?
      ((params[:page].to_i - 1) * Post.default_per_page) + idx + 1
    else
      idx + 1
    end
  end
end
