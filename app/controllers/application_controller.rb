class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  #we want SessionsHelper module to be available in all our controllers.
  include SessionsHelper
end
