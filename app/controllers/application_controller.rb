class ApplicationController < ActionController::Base
  protect_from_forgery
  require 'ruby-debug'

  def after_sign_in_path_for(resource)
    user_path(resource)
  end
  
  def after_sign_up_path_for(resource)
    edit_user_path(resource)
  end

end
