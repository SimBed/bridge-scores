class ApplicationController < ActionController::Base
  def admin_user
    redirect_to(root_url) unless user_signed_in?
  end

  def sort_direction(direction: 'asc')
    # additional code provides robust sanitisation of what goes into the order clause
    %w[asc desc].include?(params[:direction]) ? params[:direction] : direction
  end
end
