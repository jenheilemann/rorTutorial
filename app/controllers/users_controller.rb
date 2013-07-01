class UsersController < ApplicationController
  before_filter :signed_in_user,      only: [:edit,:update,:index,:destroy]
  before_filter :user_to_edit_screen, only: [:new,:create]
  before_filter :the_same_user,       only: [:edit,:update]
  before_filter :not_the_same_user,   only: :destroy
  before_filter :admin_user,          only: :destroy

  def show
    @user = User.find(params[:id])
  end

  def index
    @users = User.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      # yay!
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def update
    if @user.update_attributes(params[:user])
      #success!
      flash[:success] = "Profile updated!"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "User #{@user.name} (#{@user.id}) destroyed."
    redirect_to users_url
  end

  private

    # when peeps are attempting to access restricted areas, save where they were
    # trying to go, then send them to the sign in page. We use the saved location
    # after they sign in to redirect them back
    def signed_in_user
      unless signed_in?
        store_location
        redirect_to signin_url, notice: "Please sign in."
      end
    end

    # comparing the current user to the id being accessed. if they're not the
    # same, send user back to the root page - they shouldn't be trying to do
    # that
    def the_same_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user? @user
    end

    # signed in user shouldn't create another user - just edit their profile
    def user_to_edit_screen
      redirect_to edit_user_path(current_user) if signed_in?
    end

    # restricts access unless the current_user.admin is 'true'
    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end

    # make sure the user is acting on a different user (for delete actions, etc)
    def not_the_same_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user != @user
    end
end
