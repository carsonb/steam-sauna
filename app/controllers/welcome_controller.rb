class WelcomeController < ApplicationController
  # auth callback POST comes from Steam so we can't attach CSRF token
  skip_before_filter :verify_authenticity_token, :only => :auth_callback
  before_action :ensure_logged_in

  def index
    @friends = steam_service.retrieve_friends
    @games = steam_service.retrieve_games(user_id)
  end

  def search
    @games_to_play = steam_service.find_matching_games(params[:friends])
  end

  private

  def steam_service
    @steam_service ||= SteamService.new(user_id) if user_id
  end
end
