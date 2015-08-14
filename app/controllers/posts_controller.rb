class PostsController < ApplicationController
  before_filter :redirect_unless_xhr, except: [:show, :create]
  before_filter :get_topic, except: [:hard_delete, :soft_delete, :undelete, :approve,
                                     :unapprove, :merge, :move, :copy]

  # TODO: Factor out authorization logic
  # TODO: Re-raise all Pundit Auth exceptions?

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
      reload_and_notify "#{posts.count} post(s) soft deleted"
    rescue Pundit::NotAuthorizedError
      reload_and_warn
    end
  end

  def undelete
    posts = Post.where(id: params[:ids]).where(state: 'deleted')

    begin
      authorize posts, :moderate?
      count = posts.count
      Post.undelete(posts.pluck(:id), current_user)
      reload_and_notify "#{count} post(s) undeleted"
    rescue Pundit::NotAuthorizedError
      reload_and_warn
    end
  end

  def approve
    posts = Post.where(id: params[:ids]).where(state: 'unapproved')

    begin
      authorize posts, :moderate?
      count = posts.count
      Post.approve(posts.pluck(:id), current_user)
      reload_and_notify "#{count} post(s) approved"
    rescue Pundit::NotAuthorizedError
      reload_and_warn
    end
  end

  def unapprove
    posts = Post.where(id: params[:ids]).where(state: 'visible')

    begin
      authorize posts, :moderate?
      count = posts.count
      Post.unapprove(posts.pluck(:id), current_user)
      reload_and_notify "#{count} post(s) unapproved"
    rescue Pundit::NotAuthorizedError
      reload_and_warn
    end
  end

  def hard_delete
    posts = Post.where(id: params[:ids])

    begin
      authorize posts, :moderate?
      count = posts.count
      posts.delete_all
      reload_and_notify "#{count} post(s) hard deleted"
    rescue Pundit::NotAuthorizedError
      reload_and_warn
    end
  end

  def merge
    posts = Post.where(id: params[:sources])

    begin
      authorize posts, :moderate?
      count = posts.count

      if count < 2
        flash[:warning] = "You must select 2 or more posts to merge"
        reload_location and return
      end

      Post.merge(params[:sources], params[:destination], params[:author], params[:body], current_user)
      reload_and_notify "#{count} post(s) merged"
    rescue Pundit::NotAuthorizedError
      reload_and_warn
    end
  end

  # TODO: Redirect or link to destination topic
  def move
    posts = Post.where(id: params[:post_ids])

    begin
      authorize posts, :moderate?
      create_topic_parsed = params[:create_topic] == 'true' ? true : false
      Post.move(create_topic_parsed, current_user, params[:post_ids], params[:destination_forum_id],
                params[:new_topic_title], params[:url])
      reload_and_notify "#{posts.count} post(s) moved"
    rescue Pundit::NotAuthorizedError
      reload_and_warn
    end
  end

  # TODO: Redirect or link to destination topic
  def copy
    posts = Post.where(id: params[:post_ids])

    begin
      authorize posts, :moderate?
      create_topic_parsed = params[:create_topic] == 'true' ? true : false
      Post.copy(create_topic_parsed, current_user, params[:post_ids], params[:destination_forum_id],
                params[:new_topic_title], params[:url])
      reload_and_notify "#{posts.count} post(s) copied"
    rescue Pundit::NotAuthorizedError
      reload_and_warn
    end
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

  def reload_and_warn
    flash[:danger] = 'You are not authorized to do that'
    reload_location
  end

  def reload_and_notify(notice)
    flash[:info] = notice
    reload_location
  end

  def reload_location
    respond_to do |format|
      format.js {render inline: "location.reload();"}
    end
  end
end
