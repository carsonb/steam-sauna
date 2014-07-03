class WelcomeController < ApplicationController
  # auth callback POST comes from Steam so we can't attach CSRF token
  skip_before_filter :verify_authenticity_token, :only => :auth_callback

  def index
    auth = request.env['omniauth.auth']
    if session[:current_user]
      uid = session[:current_user][:uid].to_i
      @friends = Steam::User.friends(uid)
      @games = Steam::Player.owned_games(uid, params: {include_appinfo: 1})['games']
    end
  end

  def auth_callback
    auth = request.env['omniauth.auth']
    session[:current_user] = { :nickname => auth.info['nickname'],
                                          :image => auth.info['image'],
                                          :uid => auth.uid }
    redirect_to root_url
  end
end
