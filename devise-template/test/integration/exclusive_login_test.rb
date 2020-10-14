require "test_helper"

class ExclusiveLoginTest < ActionDispatch::IntegrationTest
  include Warden::Test::Helpers

  def setup
    Warden.test_mode!
    @admin = admins(:one)
    @user = users(:one)
    # login_as(@user, :scope => :user)
  end

  # 排他的ログインのテスト
  test "ExclusiveLoginTest" do
    # Userでログイン
    get user_session_path # /users/sign_in
    assert_response :success

    post user_session_path, params: one_user_params
    assert_response :redirect
    follow_redirect!

    assert_response :success
    assert_equal root_path, path
    # assert_equal I18n.t("devise.sessions.signed_in"), flash[:notice]

    # Userでログイン中にAdminでログインを試行するとroot_pathにリダイレクトされる
    get admin_session_path # /admins/sign_in
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_equal root_path, path

    # サインアウト
    get destroy_user_session_path
    follow_redirect!
    assert_response :success
    assert_equal root_path, path

    #
    # Adminでログイン
    #
    get admin_session_path # /users/sign_in
    assert_response :success

    post admin_session_path, params: admin_user_params
    assert_response :redirect
    follow_redirect!

    assert_response :success
    assert_equal root_path, path
    # assert_equal I18n.t("devise.sessions.signed_in"), flash[:notice]

    # Adminでログイン中にUserでログインを試行するとroot_pathにリダイレクトされる
    get user_session_path # /admins/sign_in
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
