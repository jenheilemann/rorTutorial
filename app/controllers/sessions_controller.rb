class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by_email(params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # sign in & redirect to user's "show" page.
      sign_in user
      redirect_to user
    else
      # errorz
      flash.now[:error] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    # sign the user out
    sign_out
    redirect_to root_url
  end
end
