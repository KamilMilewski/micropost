require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
	def setup
		@user = users(:kamil)
	end

	test "layout links for non logged user" do
		get root_path
		assert_template 'static_pages/home'
		assert_select "a[href=?]", root_path, count: 2
		assert_select "a[href=?]", help_path
		assert_select "a[href=?]", about_path
		assert_select "a[href=?]", contact_path

		# Those should be not be visible to non logged in user:
		assert_select "a[href=?]", users_path, count: 0
		assert_select "a[href=?]", logout_path, count: 0


		get contact_path
		assert_select "title", full_title("Contact")
	end

	test "layout links for logged in user" do
		get root_path
		log_in_as @user
		get root_path
		assert_template 'static_pages/home'
		assert_select "a[href=?]", root_path, count: 2
		assert_select "a[href=?]", help_path
		assert_select "a[href=?]", about_path
		assert_select "a[href=?]", contact_path

		# links only for logged in user
		assert_select "a[href=?]", users_path, count: 1
		# user profile page
		assert_select "a[href=?]", "/users/#{@user.id}", count: 1
		# user settinds page (user edit path)
		assert_select "a[href=?]", "/users/#{@user.id}/edit", count: 1
		assert_select "a[href=?]", logout_path, count: 1

	end

	test "get to signup page" do
		get signup_path
		assert_template 'users/new'
		assert_select 'title', full_title("Sign up")
	end
end
