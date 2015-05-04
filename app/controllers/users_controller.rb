class UsersController < ApplicationController
  def index
    @users = User.order(:username).page params[:page]
  end

  def show
    @user = User.find(params[:id])
  end
end
