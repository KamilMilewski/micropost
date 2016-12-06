class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # we want SessionsHelper module to be available in all our controllers.
  include SessionsHelper

  private

  # Confirms a logged in user
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = 'You must be logged in.'
      redirect_to login_path
    end
  end
end
