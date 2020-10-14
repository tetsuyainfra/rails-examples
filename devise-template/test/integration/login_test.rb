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

  test "User between login to signout" do
    # Login
    get user_session_path # /users/sign_in
    assert_response :success

    post user_session_path, params: one_user_params
    assert_response :redirect
    follow_redirect!

    assert_response :success
    assert_equal root_path, path

    # Signout with GET
    get destroy_user_session_path
    follow_redirect!
    assert_response :success
    assert_equal root_path, path
  end

  test "Admin between login to signout" do
    # Admin Login
    get admin_session_path # /admins/sign_in
    assert_response :success

    post admin_session_path, params: admin_user_params
    assert_response :redirect
    follow_redirect!

    assert_response :success
    assert_equal root_path, path

    # Signout with GET
    get destroy_admin_session_path
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

  def admin_user_params
    {
      admin: {
        email: admins(:one).email,
        password: "password@",
        remember_me: "0",
      },
    }
  end
end
