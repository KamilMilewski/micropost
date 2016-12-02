class PasswordResetsController < ApplicationController
  before_action :get_user,   only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update] # Case (1)

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = 'Email sent with password reset instructions'
      redirect_to root_url
    else
      flash.now[:danger] = 'Email address not found'
      render :new
    end
  end

  def edit
  end

  # Password reset cases:
  # 1. An expired password reset.
  # 2. A failed update due to an invalid password.
  # 3. A failed update due to blank password and confirmation.
  # 4. A successful update.
  def update
    if params[:user][:password].empty? # Case (3)
      @user.errors.add(:password, "can't be empty")
      render 'edit'
    elsif @user.update_attributes(user_params) # Case (4)
      log_in @user
      # After password reset on public computer some villain could just
      # press browser back button and send changed password once again. To
      # prevent this we set reset_digest attribute to nil right after
      # intended reset.
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = 'Password has been reset.'
      redirect_to @user
    else # Case (2)
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def get_user
    @user = User.find_by(email: params[:email])
  end

  # Confirm a valid user.
  def valid_user
    unless @user && @user.activated? &&
           @user.authenticated?(:reset, params[:id])
      redirect_to root_url
    end
  end

  # Checks expiration of reset token. [Case (1)]
  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = 'Password reset has expired.'
      redirect_to new_password_reset_url
    end
  end
end
