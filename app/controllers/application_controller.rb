class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :configure_steam_api_key

  def logged_in?
    session[:current_user].present?
  end

  def ensure_logged_in
    redirect_to(login_path) unless logged_in?
  end

  def user_id
    session[:current_user][:uid].to_i
  end

  private
  def configure_steam_api_key
    Steam.apikey = ENV['STEAM_API_KEY']
  end
end
