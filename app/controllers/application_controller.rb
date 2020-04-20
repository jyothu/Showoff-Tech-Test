class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  add_flash_types :success, :info, :danger, :warning
  helper_method :current_user, :user_logged_in?

  include Authenticatable
  include ExceptionHandler
end
