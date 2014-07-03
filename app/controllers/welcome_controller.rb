class WelcomeController < ApplicationController
  # auth callback POST comes from Steam so we can't attach CSRF token
  skip_before_filter :verify_authenticity_token, :only => :auth_callback

  def index
    if session[:current_user]
      uid = session[:current_user][:uid].to_i
      @friends = retrieve_friends(uid)
      @games = retrieve_games(uid)
    end
    @friends ||= []
    @games ||= []
  end

  def auth_callback
    auth = request.env['omniauth.auth']
    session[:current_user] = { :nickname => auth.info['nickname'],
                                          :image => auth.info['image'],
                                          :uid => auth.uid }
    redirect_to root_url
  end

  def retrieve_friends(uid)
    friends = Steam::User.friends(uid)
    Steam::User.summaries(friends.map{|f| f['steamid']})
  end

  def retrieve_games(uid)
    games = Steam::Player.owned_games(uid, params: {include_appinfo: 1})
    games['games']
  end
end
