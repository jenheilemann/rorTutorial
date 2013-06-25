class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper

  # force signout to prevent cross-site request forgery attacks
  def handle_unverified_request
    sign_out

    super
  end
end
