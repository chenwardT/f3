class PostsController < ApplicationController
  def show
    @post = Post.find(params[:id])
  end

  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      flash[:success] = "Post successfully created"

      # TODO: Clean up
      dummy_pager = @post.topic.posts.all.page(1).per(Post.default_per_page)
      redirect_to topic_path(params[:topic_id], page: dummy_pager.total_pages)
    else
      flash[:danger] = "Error posting reply"
      render topic_path(params[:topic_id])
    end
  end

  def soft_delete
    @post = Post.find(params[:id])
    authorize @post
    # TODO: Cleanup
    reason = params.include?(:post) ? params[:post][:reason] : nil
    @post.soft_delete(current_user, reason)

    redirect_to @post.topic
  end

  private

  # TODO: Is this OK?
  # ex. incoming parameters:
  # {"utf8"=>"✓",
  #  "authenticity_token"=>"OMkmu7fy9+uHIVSPqKIEJA8AXO9ZaghkvwneHXBg1UcAIjnJo8LTIWLQ4s0pSJZpVy2RKhiE9A/3bUnhuuuY2Q==",
  #  "topic_id"=>"5",
  #  "post"=>{"body"=>"asdasdas"},
  #  "commit"=>"Post"}

  def post_params
    params.require(:post).permit(:body).merge({topic_id: params.require(:topic_id)})
  end
end
