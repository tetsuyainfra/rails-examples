class ExclusiveLoginTest < ActionDispatch::IntegrationTest
  include Warden::Test::Helpers

  def setup
    Warden.test_mode!
    # @user = users( :john )
    # login_as(@user, :scope => :user)
  end

  test "Login" do
    get user_session_path # /users/sign_in
    assert_response :success

    post user_session_path, params: {
                              user: {
                                login: users(:one).email,
                                password: "password1",
                              },
                            }
    assert_response :redirect
    follow_redirect!

    assert_response :success
    assert_equal root_path, path
    # assert_equal I18n.t("devise.sessions.signed_in"), flash[:notice]

  end
end
