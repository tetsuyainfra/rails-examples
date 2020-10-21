require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  include Warden::Test::Helpers

  setup do
    @user = users(:one)
    @blog = blogs(:one)
    @post = posts(:one)
    @comment = comments(:one)

    @other_user = users(:two)
    @other_blog = blogs(:two)
    @other_post = posts(:two)
    @other_comment = comments(:two)
  end

  test "should get index" do
    get comments_url
    assert_response :success
  end

  test "should get new" do
    get new_comment_url
    assert_redirected_to new_user_session_path

    log_in(@user)
    get new_comment_url
    assert_response :success

    log_in(@other_user)
    get new_comment_url
    assert_response :success
  end

  test "should create comment" do
    assert_no_difference("Comment.count") do
      post comments_url, params: comment_param(@user)
    end
    assert_redirected_to new_user_session_path

    log_in(@user)
    assert_difference("Comment.count") do
      post comments_url, params: comment_param(@user)
    end
    assert_redirected_to comment_url(Comment.last)

    log_in(@other_user)
    assert_no_difference("Comment.count") do
      post comments_url, params: comment_param(@user)
    end
    assert_redirected_to root_path
  end

  test "should show comment" do
    assert_equal @blog.published?, true

    get comment_url(@comment)
    assert_response :success

    log_in(@user)
    get comment_url(@comment)
    assert_response :success

    log_in(@other_user)
    get comment_url(@comment)
    assert_response :success
  end

  test "should hide comment" do
    @blog.unpublished!
    @blog.save!
    assert_equal @blog.unpublished?, true

    get comment_url(@comment)
    assert_response :redirect

    log_in(@user)
    get comment_url(@comment)
    assert_response :success

    log_in(@other_user)
    get comment_url(@comment)
    assert_response :redirect
  end

  # 編集はできない
  test "should get edit" do
    get edit_comment_url(@comment)
    assert_response :redirect

    log_in(@user)
    get edit_comment_url(@comment)
    # assert_response :success
    assert_response :redirect

    log_in(@other_user)
    get edit_comment_url(@comment)
    assert_response :redirect
  end

  # 編集はできない
  test "should update comment" do
    patch comment_url(@comment), params: comment_param(@user)
    # assert_redirected_to comment_url(@comment)
    assert_redirected_to new_user_session_path

    log_in(@user)
    patch comment_url(@comment), params: comment_param(@user)
    # assert_redirected_to comment_url(@comment)
    assert_redirected_to root_path

    log_in(@other_user)
    patch comment_url(@comment), params: comment_param(@user)
    assert_redirected_to root_path

    patch comment_url(@comment), params: comment_param(@other_user)
    assert_redirected_to root_path
  end

  test "should destroy comment" do
    log_in(@user)
    assert_difference("Comment.count", -1) do
      delete comment_url(@comment)
    end

    assert_redirected_to comments_url
  end
  test "should not destroy comment" do
    assert_no_difference("Comment.count") do
      delete comment_url(@comment)
    end
    assert_redirected_to new_user_session_path

    log_in(@other_user)
    assert_no_difference("Comment.count") do
      delete comment_url(@comment)
    end
    assert_redirected_to root_path
  end

  private

  def comment_param(user)
    {
      comment: {
        body: @comment.body,
        name: @comment.name,
        post_id: @comment.post_id,
        user_id: user.id,
      },
    }
  end
end
