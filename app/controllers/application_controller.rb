class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def api_client
  	@api_client ||= WidgetsAPI::V1::Client.new
  end
end
