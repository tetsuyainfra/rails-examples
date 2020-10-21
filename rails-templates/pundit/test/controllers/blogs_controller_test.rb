require "test_helper"

class BlogsControllerTest < ActionDispatch::IntegrationTest
  include Warden::Test::Helpers
  # include Devise::TestHelpers

  setup do
    @user = users(:one)
    @blog = blogs(:one)
    @other_user = users(:two)
  end

  test "should get index" do
    get blogs_url
    assert_response :success
  end

  test "should get new" do
    get new_blog_url
    assert_redirected_to new_user_session_path

    log_in(@user)
    get new_blog_url
    assert_response :success

    log_in(@other_user)
    get new_blog_url
    assert_response :success
  end

  test "should create blog" do
    assert_no_difference("Blog.count") do
      post blogs_url, params: blog_params(@user)
    end
    assert_redirected_to new_user_session_path

    log_in(@user)
    assert_difference("Blog.count") do
      post blogs_url, params: blog_params(@user)
    end
    assert_redirected_to blog_url(Blog.last)

    # 他人のUserIDで作成しようとするとリダイレクト
    log_in(@other_user)
    assert_no_difference("Blog.count") do
      post blogs_url, params: blog_params(@user)
    end
    assert_redirected_to root_path
  end

  # You are not authorized to access this page.
  test "should show blog" do
    assert_equal @blog.published?, true

    get blog_url(@blog)
    assert_response :success

    log_in(@user)
    get blog_url(@blog)
    assert_response :success

    log_in(@other_user)
    get blog_url(@blog)
    assert_response :success
  end

  test "should hide blog" do
    @blog.unpublished!
    @blog.save!
    assert_equal @blog.unpublished?, true

    get blog_url(@blog)
    assert_response :redirect

    log_in(@user)
    get blog_url(@blog)
    assert_response :success

    log_in(@other_user)
    get blog_url(@blog)
    assert_response :redirect
  end

  test "should get edit" do
    get edit_blog_url(@blog)
    assert_response :redirect

    log_in(@user)
    get edit_blog_url(@blog)
    assert_response :success

    log_in(@other_user)
    get edit_blog_url(@blog)
    assert_response :redirect
  end
  test "should update blog" do
    patch blog_url(@blog), params: blog_params(@user)
    assert_redirected_to new_user_session_path

    log_in(@user)
    patch blog_url(@blog), params: blog_params(@user)
    assert_redirected_to blog_url(@blog)

    log_in(@other_user)
    patch blog_url(@blog), params: blog_params(@other_user)
    assert_redirected_to root_path
  end

  test "should destroy blog" do
    log_in(@user)
    assert_difference("Blog.count", -1) do
      delete blog_url(@blog)
    end
    assert_redirected_to blogs_url
  end
  test "should not destroy blog" do
    assert_no_difference("Blog.count") do
      delete blog_url(@blog)
    end
    assert_redirected_to new_user_session_url

    log_in(@other_user)
    assert_no_difference("Blog.count") do
      delete blog_url(@blog)
    end
    assert_redirected_to root_path
  end
  if false
    test "should update blog" do
      patch blog_url(@blog), params: { blog: { description: @blog.description, status: @blog.status, title: @blog.title, user_id: @blog.user_id } }
      assert_redirected_to blog_url(@blog)
    end

    test "should destroy blog" do
      assert_difference("Blog.count", -1) do
        delete blog_url(@blog)
      end

      assert_redirected_to blogs_url
    end
  end

  private

  def blog_params(user)
    {
      blog: {
        user_id: user.id,
        title: "blog_title",
        description: "body",
        status: "published",
      },
    }
  end
end
