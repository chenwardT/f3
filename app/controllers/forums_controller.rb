class ForumsController < ApplicationController
  def index
    @top_level_forums = Forum.where(forum_id: nil)
  end

  def show
    @forum = Forum.find(params[:id])
  end
end
