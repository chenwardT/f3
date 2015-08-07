class TopicsController < ApplicationController
  def index
    @topics = Topic.all
  end

  # TODO: Handle missing topics (e.g. following link to deleted topic)
  def show
    begin
      @topic = Topic.find(params[:id])
      register_view(@topic, current_user)
    rescue ActiveRecord::RecordNotFound
      flash[:danger] = 'Topic not found.'
      return redirect_to root_path
    end

    begin
      authorize @topic, :moderate?
      @posts = @topic.ordered_posts.page(params[:page])
    rescue Pundit::NotAuthorizedError
      @posts = @topic.visible_posts.page(params[:page])
    end

    @post = @topic.posts.build
  end

  def new
    @topic = current_user.topics.build(forum_id: params[:forum], title: 'Post New Topic')

    render 'topics/new_topic'
  end

  def create
    @topic = current_user.topics.build(topic_params)
    @post = @topic.posts.build(post_params)
    @post.user = current_user

    if @topic.save && @post.save
      flash[:success] = "New topic created"
      redirect_to @topic
    else
      flash[:danger] = "Error creating new topic"
      render forum_path(params[:forum_id])
    end
  end

  private

  def topic_params
    params.require(:topic).permit(:title, :forum_id)
  end

  def post_params
    params.require(:post).permit(:body)
  end

  # TODO: Can this just act on @topic?
  def register_view(topic, user)
    topic.register_view_by(user)
  end
end
