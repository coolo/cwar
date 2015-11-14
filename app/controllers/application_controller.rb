class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :require_user

  def require_user
    if session[:current_user_id].blank?
      Rails.logger.debug "no current user"
      redirect_to :index and return
    end
    @user = User.find(session[:current_user_id])
    Rails.logger.debug "Found user #{@user.name}"
  end
end
