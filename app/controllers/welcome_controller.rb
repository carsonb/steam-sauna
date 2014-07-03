class WelcomeController < ApplicationController
  # auth callback POST comes from Steam so we can't attach CSRF token
  skip_before_filter :verify_authenticity_token, :only => :auth_callback

  def index
    if session[:current_user]
      @friends = retrieve_friends
    end
    @friends ||= []
  end

  def auth_callback
    auth = request.env['omniauth.auth']
    session[:current_user] = { :nickname => auth.info['nickname'],
                                          :image => auth.info['image'],
                                          :uid => auth.uid }
    redirect_to root_url
  end

  def retrieve_friends
    friends = Steam::User.friends(session[:current_user][:uid].to_i)
    Steam::User.summaries(friends.map{|f| f['steamid']})
  end
end
