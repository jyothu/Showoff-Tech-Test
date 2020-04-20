class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  add_flash_types :success, :info, :danger, :warning

  include Authenticatable
  include ExceptionHandler
end
