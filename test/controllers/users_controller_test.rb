require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:kamil)
    @other_user = users(:jaszczomp)
    @non_activated_user = users(:johny)
  end

  test 'should get new' do
    get signup_path
    assert_response :success
  end

  test 'should redirect edit when not logged in' do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test 'should redirect update when not logged in' do
    patch user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test 'should not allow update admin attribute from the web' do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_not @user.admin?
    patch user_path(@user), params: {
      user: {
        name: @user.name,
        email: @user.email,
        password: '',
        password_confirmation: '',
        admin: true
      }
    }
    assert_not @user.reload.admin?
  end

  test 'should redirect edit when logged in as wrong user' do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test 'should redirect patch when logged in as wrong user' do
    log_in_as(@other_user)
    patch user_path(@user), params: {
      user: {
        name: @user.name,
        email: @user.email,
        password: '',
        password_confirmation: ''
      }
    }
    assert flash.empty?
    assert_redirected_to root_url
  end

  # Non logged users should not be allowed to access users index page
  test 'should redirect index when not logged in' do
    get users_path
    assert_redirected_to login_url
  end

  test 'should redirect destroy when not logged in' do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to login_url
  end

  test 'should redirect destroy when non logged in as admin' do
    log_in_as(@user)
    assert_no_difference 'User.count' do
      delete user_path(@other_user)
    end
    assert_redirected_to root_url
  end

  test 'should reditect show when user not activated' do
    log_in_as(@user)
    get user_path @non_activated_user
    assert_redirected_to root_url
  end

  test 'should redirect followers when not logged in' do
    get followers_user_path(@user)
    assert_redirected_to login_url
  end

  test 'should redirect following when not logged in' do
    get followers_user_path(@user)
    assert_redirected_to login_url
  end
end
