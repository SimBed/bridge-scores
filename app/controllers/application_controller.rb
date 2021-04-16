class ApplicationController < ActionController::Base
  def admin_user
    redirect_to(root_url) unless (user_signed_in?)
  end
end
