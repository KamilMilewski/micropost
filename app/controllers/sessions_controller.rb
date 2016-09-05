class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in(user)
      redirect_to user
    else
      #flash.now has been used here because we want this meddage to be displayed
      #only on rendered page and not on a page displayed after another request.
      flash.now[:danger] = 'Not quite right'
      render 'new'
    end
  end

  def destroy
    log_out
    redirect_to root_path
  end
end
