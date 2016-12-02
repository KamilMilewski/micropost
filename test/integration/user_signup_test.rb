require 'test_helper'

class UserSignupTest < ActionDispatch::IntegrationTest
  def setup
    # deliveries keeps an array of all the emails sent out through the
    # ActionMailer with delivery method :test
    ActionMailer::Base.deliveries.clear
  end

  test 'valid signup information with account activation' do
    # go to signup page and test if form action is correct
    get signup_path
    assert_response :success
    assert_select 'form[action=?]', '/users'

    # test if creating user with valid data will succeed
    # and 1 user will be created
    assert_difference 'User.count', 1 do
      post signup_path, params: {
        user: {
          name:                   'valid username',
          email:                  'valid@user.email',
          password:               'valid_password',
          password_confirmation:  'valid_password'
        }
      }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    # assigns method allows to access controller instance variables
    # (analogous to accessing controller variables in views)
    # :user in this case relates to @user variable defined in session controller
    user = assigns(:user)
    assert_not user.activated?
    # Try to log in before activation.
    log_in_as(user)
    assert_not is_logged_in?
    # Invalid activation token
    get edit_account_activation_path('invalid token', email: user.email)
    assert_not is_logged_in?
    # Valid token, wrong email
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    # Valid activation token
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end

  test 'invalid signup submission' do
    # go to signup page and test if form action is correct
    get signup_path
    assert_response :success
    assert_select 'form[action=?]', '/users'

    # test if creating user with invalid data will be rejected
    assert_no_difference 'User.count' do
      post signup_path, params: {
        user: {
          name: ' ',
          email: 'invalid@email',
          password: 'password',
          password_confirmation: 'dosent match'
        }
      }
    end

    # make sure errors has been displayed
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
    assert_select 'ul'
    assert_select 'li'

    assert_not is_logged_in?
  end
end
