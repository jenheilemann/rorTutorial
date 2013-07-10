class MicropostsController < ApplicationController
  # signed_in_user is in the SessionsHelper, included in ApplicationController
  before_filter :signed_in_user
  before_filter :correct_user, only: :destroy

  # handles the root page for logged in users
  def show
    @micropost = current_user.microposts.build(params[:micropost])
    @microposts = current_user.feed.paginate(page: params[:page])
  end

  def create
    @micropost = current_user.microposts.build(params[:micropost])
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @microposts = current_user.feed.paginate(page: params[:page])
      render 'show'
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted."
    redirect_to root_url
  end

private
  def correct_user
    @micropost = current_user.microposts.find_by_id(params[:id])
    redirect_to root_url if @micropost.nil?
  end
end