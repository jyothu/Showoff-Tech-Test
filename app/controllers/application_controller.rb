class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  add_flash_types :success, :info, :danger, :warning
  helper_method :current_user, :user_logged_in?

  rescue_from Faraday::ConnectionFailed, with: :no_network
  rescue_from ApiExceptions::UnauthorizedError, with: :render_422

  def api_client
  	@api_client ||= if user_logged_in?
      WidgetsAPI::V1::Client.new(access_token: current_user['access_token'], token_type: current_user['token_type'])
    else
      WidgetsAPI::V1::Client.new
    end
  end

  def current_user
    return unless user_logged_in?

    @current_user ||= User.find_by_email(session[:user_email])
  end

  def user_logged_in?
    session[:user_email].present?
  end

  def sign_in(user)
    return if user.blank?

    byebug

    session[:user_email] = user['email'] || user[:email]
  end

  def sign_out
    session[:user_email] = nil
  end

  private

  def no_network(exception)
    @exception = 'Please check your connectivity. Seems like you are not connected to internet'
    render 'layouts/no_network.html.haml', layout: 'exception_layout'
  end

  def render_422(exception)
    # sign_out
    redirect_to root_path, warning: exception
  end
end
