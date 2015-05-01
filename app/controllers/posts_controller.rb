class PostsController < ApplicationController
  def show
    @post = Post.find(params[:id])
  end

  def create
    @post = Post.new(post_params)
    @post.user = current_user
    @post.topic_id = params[:topic_id]

    if @post.save
      flash[:success] = "Post successfully created"
    else
      flash[:danger] = "Error posting reply"
    end

    redirect_to topic_path(@post.topic)
  end

  private

  def post_params
    params.require(:post).permit(:body)
  end
end
