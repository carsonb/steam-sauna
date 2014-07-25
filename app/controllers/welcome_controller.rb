class WelcomeController < ApplicationController
  # auth callback POST comes from Steam so we can't attach CSRF token
  skip_before_filter :verify_authenticity_token, :only => :auth_callback
  before_action :ensure_logged_in

  def index
    @friends = retrieve_friends
    @games = retrieve_games
  end

  def search
    @games_to_play = steam_service.find_matching_games(params[:friends])
  end

  def retrieve_friends
    current_user.update_friends unless current_user.friends?
    User.fetch_and_or_store(current_user.friends)
  end

  def retrieve_games
    steam_service.retrieve_games(current_user.uid)
  end

  private

  def steam_service
    @steam_service ||= SteamService.new(current_user.uid) if logged_in?
  end
end
