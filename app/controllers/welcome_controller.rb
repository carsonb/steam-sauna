class WelcomeController < ApplicationController
  # auth callback POST comes from Steam so we can't attach CSRF token
  skip_before_filter :verify_authenticity_token, :only => :auth_callback
  before_action :ensure_logged_in

  def index
    @friends = retrieve_friends
    @games = retrieve_games(user_id)
  end

  def search

  end

  def retrieve_friends
    begin
      friends = Steam::User.friends(user_id)
    rescue Steam::JSONError
      friends = []
    end
    Steam::User.summaries(friends.map{|f| f['steamid']})
  end

  def retrieve_games(uid)
    begin
      games = Steam::Player.owned_games(uid, params: {include_appinfo: 1})
    rescue Steam::JSONError
      games = []
    end
    games['games']
  end
end
