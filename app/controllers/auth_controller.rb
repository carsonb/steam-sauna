class AuthController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :callback
  before_action :send_to_welcome, only: :index

  def index
  end

  def callback
    auth = request.env['omniauth.auth']
    session[:current_user] = {
      :nickname => auth.info['nickname'],
      :image => auth.info['image'],
      :uid => auth.uid
    }
    redirect_to root_url
  end

  private
  def send_to_welcome
    redirect_to(root_path) if logged_in?
  end
end
