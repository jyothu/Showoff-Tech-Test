module Authenticatable
  extend ActiveSupport::Concern

  def current_user
    return unless user_logged_in?

    @current_user ||= User.find_by_email(session[:user_email])
  end

  def user_logged_in?
    session[:user_email].present?
  end

  def sign_in(user)
    return if user.blank?

    session[:user_email] = user['email'] || user[:email]
  end

  def sign_out
    begin
      api_client.revoke_token(revoke_params)
      session[:user_email] = nil
      flash[:info] = 'Logged out!'
    rescue => e
      flash[:danger] = e.message
    end
  end

  def api_client
  	@api_client ||= if user_logged_in?
      WidgetsAPI::V1::Client.new(access_token: current_user['access_token'], token_type: current_user['token_type'])
    else
      WidgetsAPI::V1::Client.new
    end
  end

  private

  def revoke_params
    { token: current_user['access_token'] }
  end
end