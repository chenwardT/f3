class TopicsController < ApplicationController
  def index
    @topics = Topic.all
  end

  def show
    @topic = Topic.find(params[:id])
    @post = Post.new
  end
end
