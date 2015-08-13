class PostsController < ApplicationController
  before_filter :redirect_unless_xhr, except: [:show, :create]
  before_filter :get_topic, except: [:hard_delete, :soft_delete, :undelete, :approve,
                                     :unapprove, :merge]

  # Unused; posts are linked via topic#show + page param + post ID anchor
  def show
    @post = Post.find(params[:id])
  end

  # TODO: Handle missing user, topic (id)
  def create
    @post = @topic.posts.build(post_params)
    @post.user = current_user

    if @post.save
      flash[:success] = "Post successfully created"
    else
      error_msg = "Error posting reply: "
      @post.errors.full_messages.each { |msg| error_msg += msg }
      flash[:danger] = error_msg
    end

    redirect_to controller: 'topics', action: 'show', id: @topic.id, page: last_page_of_topic
  end

  def soft_delete
    # Note: We don't filter on state here, since unapproved posts should also be deleted
    # and, if then undeleted, should be considered "approved" and thus visible.
    posts = Post.where(id: params[:ids])

    if params.key? :reason
      reason = params[:reason]
    else
      reason = nil
    end

    begin
      authorize posts, :moderate?
      Post.soft_delete(params[:ids], current_user, reason)
      render nothing: true
    rescue Pundit::NotAuthorizedError
      flash[:danger] = 'You are not authorized to do that'
      redirect_to forums_path
    end
  end

  def undelete
    posts = Post.where(id: params[:ids]).where(state: 'deleted')

    begin
      authorize posts, :moderate?
      Post.undelete(posts.pluck(:id), current_user)
      render nothing: true
    rescue Pundit::NotAuthorizedError
      flash[:danger] = 'You are not authorized to do that'
      redirect_to forums_path
    end
  end

  def approve
    posts = Post.where(id: params[:ids]).where(state: 'unapproved')
    authorize posts, :moderate?

    Post.approve(posts.pluck(:id), current_user)

    render nothing: true
  end

  def unapprove
    posts = Post.where(id: params[:ids]).where(state: 'visible')
    authorize posts, :moderate?

    Post.unapprove(posts.pluck(:id), current_user)

    render nothing: true
  end

  def hard_delete
    posts = Post.where(id: params[:ids])

    begin
      authorize posts, :moderate?
      posts.delete_all
      render nothing: true  # TODO: Can we just return?
    rescue Pundit::NotAuthorizedError
      flash[:danger] = 'You are not authorized to do that'
      redirect_to forums_path
    end
  end

  def merge
    posts = Post.where(id: params[:sources])

    begin
      authorize posts, :moderate?
      Post.merge(params[:sources], params[:destination], params[:author], params[:body], current_user)
      render nothing: true
    rescue Pundit::NotAuthorizedError
      flash[:danger] = 'You are not authorized to do that'
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
    params.require(:post).permit(:body, :topic_id)
  end

  def get_topic
    @topic = Topic.find(params[:post][:topic_id])
  end

  def last_page_of_topic
    dummy_pager = @topic.posts.all.page(1).per(Post.default_per_page)
    dummy_pager.total_pages
  end

  def redirect_unless_xhr
    redirect_to forums_path unless request.xhr?
  end
end
