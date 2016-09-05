require 'test_helper'

class UserSignupTest < ActionDispatch::IntegrationTest

  test "valid signup submission" do
    #go to signup page and test if form action is correct
    get signup_path
    assert_response :success
    assert_select "form[action=?]", "/signup"

    #test if creating user with valid data will succeed
    #and 1 user will be created
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

    #make sure message has been displayed
    follow_redirect!
    assert_template 'users/show'
    assert_select "div.alert-success"
    assert_not flash.empty?
    assert is_logged_in?
  end

  test "invalid signup submission" do
    #go to signup page and test if form action is correct
    get signup_path
    assert_response :success
    assert_select "form[action=?]", "/signup"

    #test if creating user with invalid data will be rejected
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

    #make sure errors has been displayed
    assert_template 'users/new'
    assert_select "div#error_explanation"
    assert_select "div.field_with_errors"
    assert_select 'ul'
    assert_select 'li'

    assert_not is_logged_in?
  end
end
