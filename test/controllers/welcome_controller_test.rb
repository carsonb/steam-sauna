require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase
  test "should be redirected to login page" do
    get :index
    assert_redirected_to login_path
  end

end
