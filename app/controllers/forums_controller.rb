class ForumsController < ApplicationController
  # TODO: Filter forums by viewable by current_user
  def index
    @top_level_forums = policy_scope(Forum.where(forum_id: nil).order(created_at: :asc))
  end

  def show
    @forum = Forum.find(params[:id])

    begin
      authorize @forum
    rescue Pundit::NotAuthorizedError
      flash[:danger] = NOT_AUTHORIZED_MSG
      redirect_to (request.referrer || root_path)
    end

    register_view
  end

  private
  def register_view
    @forum.register_view_by(current_user)
  end
end
