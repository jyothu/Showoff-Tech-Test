class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  add_flash_types :success, :info, :danger, :warning

  def api_client
  	@api_client ||= WidgetsAPI::V1::Client.new
  end
end
