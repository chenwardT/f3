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
    if request.xhr?
      # Note: We don't filter on state here, since unapproved posts should also be deleted
      # and, if then undeleted, should be considered "approved" and thus visible.
      posts = Post.where(id: params[:ids])
      reason = params.key? :reason ? params[:reason] : nil
      authorize posts, :moderate?

      Post.soft_delete(params[:ids], current_user, reason)

      render nothing: true
    else
      redirect_to forums_path
    end
  end

  def undelete
    if request.xhr?
      posts = Post.where(id: params[:ids]).where(state: 'deleted')
      authorize posts, :moderate?

      Post.undelete(posts.pluck(:id), current_user)

      render nothing: true
    else
      redirect_to forums_path
    end
  end

  def approve
    if request.xhr?
      posts = Post.where(id: params[:ids]).where(state: 'unapproved')
      authorize posts, :moderate?

      Post.approve(posts.pluck(:id), current_user)

      render nothing: true
    else
      redirect_to forums_path
    end
  end

  def unapprove
    if request.xhr?
      posts = Post.where(id: params[:ids]).where(state: 'visible')
      authorize posts, :moderate?

      Post.unapprove(posts.pluck(:id), current_user)

      render nothing: true
    else
      redirect_to forums_path
    end
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
