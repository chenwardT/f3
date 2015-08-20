class TopicsController < ApplicationController
  def show
    # TODO: Compare rescue with exists? check
    begin
      @topic = Topic.find(params[:id])

      begin
        authorize @topic
      rescue Pundit::NotAuthorizedError
        redirect_to (request.referrer || root_path) and return
      end

      register_view(@topic, current_user)
    rescue ActiveRecord::RecordNotFound
      flash[:danger] = 'Topic not found'
      redirect_to (request.referrer || root_path) and return
    end

    # TODO: authorize view_unapproved_posts
    begin
      authorize @topic.forum, :moderate?
      @posts = @topic.ordered_posts.includes(:user).page(params[:page])
      @forum_list = generate_forum_hierarchy
    rescue Pundit::NotAuthorizedError
      @posts = @topic.visible_posts.includes(:user).page(params[:page])
    end

    @post = @topic.posts.build
  end

  def new
    @topic = current_user.topics.build(forum_id: params[:forum], title: 'Post New Topic')

    begin
      authorize @topic
    rescue Pundit::NotAuthorizedError
      flash[:danger] = 'You are not authorized to do that'
      redirect_to (request.referrer || root_path) and return
    end
  end

  # TODO: Save topic title and post body in displayed form when error on save
  def create
    @topic = current_user.topics.build(topic_params)

    begin
      authorize @topic.forum, :create_topic?
    rescue Pundit::NotAuthorizedError
      flash[:danger] = 'You are not authorized to do that'
      redirect_to (request.referrer || root_path) and return
    end

    if @topic.save
      @post = @topic.posts.build(post_params)
      @post.user = current_user

      if @post.save
        flash[:success] = "New topic created"
        redirect_to @topic
      else
        @topic.delete
        render :new
      end
    else
      render :new
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

  def generate_forum_hierarchy
    options = []

    Forum.all.each do |f|
      options << [f.id, f.breadcrumb]
    end

    options.sort.to_json
  end
end
