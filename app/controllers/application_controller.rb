class ApplicationController < ActionController::Base
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_or_guest_user

  before_action :configure_permitted_parameters, if: :devise_controller?

  def authenticate_admin_user!
    redirect_to new_user_session_path unless user_signed_in? && current_user.is_admin?
  end

  # If user is logged in, return current_user, else return guest_user
  def current_or_guest_user
    if current_user
      if session[:guest_user_id] && session[:guest_user_id] != current_user.id
        # logging_in
        guest_user(with_retry=false).try(:destroy)
        session[:guest_user_id] = nil
      end
      current_user
    else
      guest_user
    end
  end

  def pundit_user
    current_or_guest_user
  end

  # Find guest_user object associated with the current session, creating one as needed.
  def guest_user(with_retry=true)
    @cached_guest_user ||= User.find(session[:guest_user_id] ||= create_guest_user.id)

  rescue ActiveRecord::RecordNotFound # If session[:guest_user_id] invalid
    session[:guest_user_id] = nil
    guest_user if with_retry
  end

  def reload_and_warn
    flash[:danger] = NOT_AUTHORIZED_MSG
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

  def user_for_paper_trail
    current_or_guest_user
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :username
  end

  private

  def create_guest_user
    user = User.create(email: "guest_#{Time.now.to_i}#{rand(100)}@example.com", username: "guest")
    user.groups << Group.guest
    user.save!(validate: false)
    session[:guest_user_id] = user.id
    user
  end
end
