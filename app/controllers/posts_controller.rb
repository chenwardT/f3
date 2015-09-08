class PostsController < ApplicationController
  before_filter :redirect_unless_xhr, except: [:show, :create, :update]
  before_filter :get_topic, except: [:hard_delete, :soft_delete, :undelete, :approve,
                                     :unapprove, :merge, :move, :copy, :update]

  # TODO: Factor out authorization logic
  # TODO: Re-raise all Pundit Auth exceptions?

  # Unused for now; posts are linked via topic#show + page param + post ID anchor
  # def show
  #   @post = Post.find(params[:id])
  # end

  # TODO: Handle missing user, topic (id)
  def create
    @post = @topic.posts.build(post_params)
    @post.user = current_user

    begin
      authorize @post
    rescue Pundit::NotAuthorizedError
      flash[:danger] = NOT_AUTHORIZED_MSG
      redirect_to (request.referrer || root_path) and return
    end

    set_approval_state

    if @post.save
      set_flash_from_state
    else
      error_msg = "Error posting reply: "
      @post.errors.full_messages.each { |msg| error_msg += msg }
      flash[:danger] = error_msg
    end

    redirect_to controller: 'topics', action: 'show', id: @topic.id, page: last_page_of_topic
  end

  def update
    @post = Post.find(params[:id])

    begin
      authorize @post
    rescue Pundit::NotAuthorizedError
      reload_and_warn and return
    end

    @post.body = params[:body]

    # TODO: Edit reason

    unless @post.save
      error_msg = "Error editing post: "
      @post.errors.full_messages.each { |msg| error_msg += msg }
      flash[:danger] = error_msg
      reload_location and return
    end

    # TODO: Redirect to @post page, and @post anchor
    reload_and_notify("Post successfully edited.")
  end

  # TODO: Currently assumes all posts are in the same forum.
  # As such, authorization is performed against the first post.
  def soft_delete
    # Note: We don't filter on state here, since unapproved posts should also be deleted
    # and, if then undeleted, should be considered "approved" and thus visible.
    posts = Post.where(id: params[:ids])
    params.key? :reason ? reason = params[:reason] : reason = nil

    begin
      authorize posts.first   # TODO: Check permissions on all posts.
    rescue Pundit::NotAuthorizedError
      reload_and_warn and return
    end

    Post.soft_delete(params[:ids], current_user, reason)
    reload_and_notify "#{posts.count} post(s) soft deleted"
  end

  def undelete
    posts = Post.where(id: params[:ids]).where(state: 'deleted')

    begin
      authorize posts.first, :soft_delete?
    rescue Pundit::NotAuthorizedError
      reload_and_warn and return
    end

    count = posts.count
    Post.undelete(posts.pluck(:id), current_user)
    reload_and_notify "#{count} post(s) undeleted"
  end

  def approve
    posts = Post.where(id: params[:ids]).where(state: 'unapproved')

    begin
      authorize posts.first
    rescue Pundit::NotAuthorizedError
      reload_and_warn and return
    end

    count = posts.count
    Post.approve(posts.pluck(:id), current_user)
    reload_and_notify "#{count} post(s) approved"
  end

  def unapprove
    posts = Post.where(id: params[:ids]).where(state: 'visible')

    begin
      authorize posts.first, :approve?
    rescue Pundit::NotAuthorizedError
      reload_and_warn and return
    end

    count = posts.count
    Post.unapprove(posts.pluck(:id), current_user)
    reload_and_notify "#{count} post(s) unapproved"
  end

  def hard_delete
    posts = Post.where(id: params[:ids])

    begin
      authorize posts.first
    rescue Pundit::NotAuthorizedError
      reload_and_warn and return
    end

    count = posts.count
    posts.delete_all
    reload_and_notify "#{count} post(s) hard deleted"
  end

  def merge
    posts = Post.where(id: params[:sources])

    begin
      authorize posts.first   # TODO: Check perms across multiple posts.
    rescue Pundit::NotAuthorizedError
      reload_and_warn and return
    end

    count = posts.count

    if count < 2
      flash[:warning] = "You must select 2 or more posts to merge"
      reload_location and return
    end

    Post.merge(params[:sources], params[:destination], params[:author], params[:body], current_user)
    reload_and_notify "#{count} post(s) merged"
  end

  # TODO: Redirect or link to destination topic
  def move
    posts = Post.where(id: params[:post_ids])

    begin
      authorize posts.first # TODO: Check permissions for multiple posts.
    rescue Pundit::NotAuthorizedError
      reload_and_warn and return
    end

    create_topic_parsed = params[:create_topic] == 'true' ? true : false
    Post.move(create_topic_parsed, current_user, params[:post_ids], params[:destination_forum_id],
              params[:new_topic_title], params[:url])
    reload_and_notify "#{posts.count} post(s) moved"
  end

  # TODO: Redirect or link to destination topic
  def copy
    posts = Post.where(id: params[:post_ids])

    begin
      authorize posts.first # TODO: Check params across multiple posts.
    rescue Pundit::NotAuthorizedError
      reload_and_warn and return
    end

    create_topic_parsed = params[:create_topic] == 'true' ? true : false
    Post.copy(create_topic_parsed, current_user, params[:post_ids], params[:destination_forum_id],
              params[:new_topic_title], params[:url])
    reload_and_notify "#{posts.count} post(s) copied"
  end

  private

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

  def set_approval_state
    begin
      authorize @post, :preapproved_posts?
    rescue Pundit::NotAuthorizedError
      @post.state = :unapproved
    end
  end

  def set_flash_from_state
    if @post.unapproved?
      flash[:success] = "Your post will not be visible by other until approved by a moderator"
    else
      flash[:success] = "Post successfully created"
    end
  end
end
