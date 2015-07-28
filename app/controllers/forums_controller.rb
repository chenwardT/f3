class ForumsController < ApplicationController
  def index
    @top_level_forums = Forum.where(forum_id: nil).order(created_at: :asc)
  end

  def show
    @forum = Forum.find(params[:id])
    register_view
  end

  private
  def register_view
    @forum.register_view_by(current_user)
  end
end
