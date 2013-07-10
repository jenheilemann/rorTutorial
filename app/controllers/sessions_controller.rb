class SessionsController < ApplicationController
  before_filter :signed_in_user, only: [:new, :create]

  def new
  end

  def create
    user = User.find_by_email(params[:email].downcase)
    if user && user.authenticate(params[:password])
      # sign in & redirect to home page.
      sign_in user
      redirect_back_or root_url
    else
      # errorz
      flash.now[:error] = 'Invalid email/password combination.'
      render 'new'
    end
  end

  def destroy
    # sign the user out
    sign_out
    flash[:success] = "You've been signed out."
    redirect_to signin_path
  end

private

  def signed_in_user
    # signed in users don't need the login form
    redirect_to user_path(current_user) if signed_in?
  end
end
