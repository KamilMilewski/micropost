module SessionsHelper
  def log_in(user)
    # session is Rails build in method. In this case it will store encrypter
    # user.id in a TEMPORARY cookie under key :user_id. Cookies created with
    # session expire after browser close.
    session[:user_id] = user.id
  end

  # Remembers user in persistent session.
  def remember(user)
    # Save remember_digest (BCrypt'ed remember_token to the DB)
    user.remember
    # Store signed (and encrypted) user.id in permanent cookie
    cookies.permanent.signed[:user_id] = user.id
    # Store remember_token in permanent cookie
    cookies.permanent[:remember_token] = user.remember_token
  end

  def forget(user)
    # Deleting user remember_digest from db.
    user.forget
    # Deleting cookies used for remembering user.
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # Logs out the current user.
  def log_out
    # current_user is session_helper method
    forget(current_user) if logged_in?
    session.delete(:user_id)
    @current_user = nil
  end

  # Sets the current logged-in user (if any) in @current_user variable
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: session[:user_id])
    # cookies.signed because we expect :user_id in the cookie to be signed
    # so this line first decipher :user_id in a cookie and then do an assignment
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @currnt_user = user
      end
    end
  end

  def current_user?(user)
    user == current_user
  end

  # returns true if user is loggen in
  def logged_in?
    !current_user.nil?
  end

  # Redirects to stored location (or default)
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # Stores the URL trying to be accessed
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
