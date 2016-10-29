require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @non_admin  = users(:kamil)
    @admin = users(:jaszczomp)
    @non_activated_user = users(:johny)
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.where(activated: true).paginate(page: 1, per_page: 30)
    first_page_of_users.each do |user|
      assert_select "a[href=?]", user_path(user), text: user.name
      unless user == @admin
        assert_select "a[href=?]", user_path(user), text: 'delete'
      end
    end

    # Assure that non activated user isn't visible
    assert_select "a[href=?]", user_path(@non_activated_user),
                                text: @non_activated_user.name, count: 0

    # Delete one of non admin users:
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "index as non_admin" do
    log_in_as @non_admin
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
end
