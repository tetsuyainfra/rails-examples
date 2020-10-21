require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  include Warden::Test::Helpers

  setup do
    @user = users(:one)
    @blog = blogs(:one)
    @post = posts(:one)

    @other_user = users(:two)
    @other_blog = blogs(:two)
    @other_post = posts(:two)
  end

  test "should get index" do
    get posts_url
    assert_response :success
  end

  test "should get new" do
    get new_post_url
    assert_redirected_to new_user_session_path

    log_in(@user)
    get new_post_url
    assert_response :success

    log_in(@other_user)
    get new_post_url
    assert_response :success
  end

  test "should create post" do
    assert_no_difference("Post.count") do
      post posts_url, params: post_params(@user)
    end
    assert_redirected_to new_user_session_path

    log_in(@user)
    assert_difference("Post.count") do
      post posts_url, params: post_params(@user)
    end
    assert_redirected_to post_url(Post.last)

    # 他人のUserIDで作成しようとするとリダイレクト
    log_in(@other_user)
    assert_no_difference("Post.count") do
      post posts_url, params: post_params(@user)
    end
    assert_redirected_to root_path
  end

  test "should show post" do
    assert_equal @blog.published?, true

    get post_url(@post)
    assert_response :success

    log_in(@user)
    get post_url(@post)
    assert_response :success

    log_in(@other_user)
    get post_url(@post)
    assert_response :success
  end

  test "should hide blog" do
    @blog.unpublished!
    @blog.save!
    assert_equal @blog.unpublished?, true

    get post_url(@post)
    assert_response :redirect
    # assert_redirected_to new_user_session_path

    log_in(@user)
    get post_url(@post)
    assert_response :success

    log_in(@other_user)
    get post_url(@post)
    assert_response :redirect
    # assert_redirected_to root_path
  end

  test "should get edit" do
    get edit_post_url(@post)
    assert_response :redirect

    log_in(@user)
    get edit_post_url(@post)
    assert_response :success

    log_in(@other_user)
    get edit_post_url(@post)
    assert_response :redirect
  end

  test "should update post" do
    patch post_url(@post), params: post_params(@user)
    assert_redirected_to new_user_session_path

    log_in(@user)
    patch post_url(@post), params: post_params(@user)
    assert_redirected_to post_url(@blog)

    log_in(@other_user)
    patch post_url(@post), params: post_params(@other_user)
    assert_redirected_to root_path
  end

  test "should destroy post" do
    log_in(@user)
    assert_difference("Post.count", -1) do
      assert_difference("Comment.count", -1) do
        delete post_url(@post)
      end
    end
    assert_redirected_to posts_url
  end
  test "should not destroy post" do
    assert_no_difference("Post.count") do
      assert_no_difference("Comment.count") do
        delete post_url(@post)
      end
    end
    assert_redirected_to new_user_session_path

    log_in(@other_user)
    assert_no_difference("Post.count") do
      assert_no_difference("Comment.count") do
        delete post_url(@post)
      end
    end
    assert_redirected_to root_path
  end

  private

  def post_params(user)
    {
      post: {
        blog_id: @post.blog_id,
        user_id: user.id,
        body: @post.body,
        title: @post.title,
      },
    }
  end
end
