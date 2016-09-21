require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:kamil)
  end

  # if non logged user tries to open edit profile page he should be redirected
  # first to login page. Then when he is logged in he should be redirected to
  # page he tried to enter - in this case user edit page
  test 'successful edit with friendly forwarding' do
    get edit_user_path @user
    log_in_as @user
    assert_redirected_to edit_user_path @user
    assert_nil session[:forwarding_url]

    name = 'valid edited user name'
    email = 'valid.edited@user.email'
    patch user_path(@user), params: {
      user: {
        name:                  name,
        email:                 email,
        password:              '',
        password_confirmation: ''
      }
    }

    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end

  test 'unsuccessful edit' do
    log_in_as @user

    get edit_user_path(@user)
    assert_response :success
    assert_template 'users/edit'

    patch user_path(@user), params: {
      user: {
        name:                  'name',
        email:                 'valid@user.email',
        password:              'valid_password',
        password_confirmation: 'invalid_password_confirmation'
      }
    }

    errors_count = @user.errors.messages.count
    assert_template 'users/edit'
    assert_select "div#error_explanation"
    assert_select "div.alert-danger",  {text: 'The form contains 1 error.'}
    assert_select "div.field_with_errors"
    assert_select 'ul'
    assert_select 'li'
  end
end
