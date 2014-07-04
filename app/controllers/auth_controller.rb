class AuthController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :callback
  before_action :send_to_welcome, only: :index

  def index
  end

  def callback
    auth = request.env['omniauth.auth']

    user = User.where(uid: auth.uid.to_i).first_or_initialize
    user.update_attributes(auth.info.slice('nickname', 'image'))
    session[:current_user] = user.id

    redirect_to root_url
  end

  private
  def send_to_welcome
    redirect_to(root_path) if logged_in?
  end
end
