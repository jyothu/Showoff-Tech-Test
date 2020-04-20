class UsersController < ApplicationController
  before_action :validate_password, only: [:create, :change_password]

  def show
    response = api_client.get_user(params[:id])
    @user = response.dig('data', 'user')
  end

  def create
    return if @error.present?

    begin
      response = api_client.create_user(user_params)
      User.create(redis_params(response))
      sign_in(permitted_params.slice(:email))
      redirect_to root_path, success: 'User is created and logged in successfully!'
    rescue => e
      @error = e.message
    end
  end

  def me
    response = api_client.my_profile
    @user = response.dig('data', 'user')
  end

  def update_profile
    begin
      response = api_client.change_password(user_params)
      User.create(redis_params(response))
      redirect_to me_users_path, success: 'User is updated successfully!'
    rescue => e
      @error = e.message
    end
  end

  def change_password
    return if @error.present?

    begin
      response = api_client.change_password(change_password_params)
      User.create(redis_params(response))
      redirect_to me_users_path, success: 'Password is updated successfully!'
    rescue => e
      @error = e.message
    end
  end

  def reset_password
    begin
      response = api_client.reset_password(reset_password_params)
      redirect_to root_path, success: response['message']
    rescue => e
      @error = e.message
    end
  end

  private

  def permitted_params
    params.permit(:email, :first_name, :last_name, :password, :current_password, :new_password, :date_of_birth).to_h
  end

  def validate_password
    password = params.has_key?(:password) ? params[:password] : params[:new_password]
    @error = "Password doesn't match" if password != params[:password_confirmation]
  end

  def change_password_params
    { user: permitted_params.slice(:current_password, :new_password) }
  end

  def reset_password_params
    { user: permitted_params.slice(:email) }
  end

  def redis_params(response)
    user = response.dig('data', 'user')&.slice('name', 'email', 'id') || default_params
    token = response.dig('data', 'token')&.slice('access_token', 'token_type', 'expires_in', 'refresh_token') || {}
    user.merge(token)
  end

  def user_params
    { user: permitted_params }
  end

  def default_params
    { email: current_user['email'] }
  end
end
