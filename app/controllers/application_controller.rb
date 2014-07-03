class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :configure_steam_api_key

  private
  def configure_steam_api_key
    Steam.apikey = ENV['STEAM_API_KEY']
  end
end
