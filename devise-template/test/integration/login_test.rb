require "test_helper"

class LoginTest < ActionDispatch::IntegrationTest
  include Warden::Test::Helpers

  def setup
    Warden.test_mode!
    @user = users(:one)
    @other_user = users(:two)
    # ActionController::Base.allow_forgery_protection = true # CSRF tokenの有効化
  end

  def teardown
    # ActionController::Base.allow_forgery_protection = false
  end

  test "LoginToSignout" do
    get user_session_path # /users/sign_in
    assert_response :success

    post user_session_path, params: one_user_params
    assert_response :redirect
    follow_redirect!

    assert_response :success
    assert_equal root_path, path
  end

  def one_user_params
    {
      user: {
        login: users(:one).email,
        # email: users(:one).email,
        password: "password1",
        remember_me: "0",
      },
    }
  end
end
