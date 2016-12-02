class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user && @user.authenticate(params[:session][:password])
      if @user.activated?
        log_in @user
        params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
        # Friendly forwarding:
        redirect_back_or @user
      else
        message = 'Account not activated. '
        message += 'Check your email for activation link.'
        flash[:warning] = message
        redirect_to root_url
      end
    else
      # Flash.now has been used here because we want this message to be displayed
      # only on rendered page and not on a page displayed after another request.
      flash.now[:danger] = 'Not quite right'
      render 'new'
    end
  end

  def destroy
    log_out
    redirect_to root_path
  end
end
