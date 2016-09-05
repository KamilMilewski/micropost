module SessionsHelper
  def log_in(user)
    #session is Rails build in method. In this case it will store encrypter
    #user.id in a TEMPORARY cookie under key :user_id. Cookies created with
    #session expire after browser close.
    session[:user_id] = user.id
  end

  # Logs out the current user.
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end

  #returns the current logged-in user (if any)
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  #returns true if user is loggen in
  def logged_in?
    !current_user.nil?
  end
end
