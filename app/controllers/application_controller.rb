class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  helper_method :current_user
  protect_from_forgery with: :exception

  before_filter :configure_steam_api_key

  def log_in(user)
    session[:user_id] = user.id
  end

  def logged_in?
    current_user.present?
  end

  def ensure_logged_in
    redirect_to(login_path) unless logged_in?
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def user_id
    current_user.uid
  end

  private
  def configure_steam_api_key
    Steam.apikey = ENV['STEAM_API_KEY']
  end
end
