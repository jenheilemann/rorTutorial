class MicropostsController < ApplicationController
  # signed_in_user is in the SessionsHelper, included in ApplicationController
  before_filter :signed_in_user

  def create
  end

  def destroy
  end
end