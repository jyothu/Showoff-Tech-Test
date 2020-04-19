class UsersController < ApplicationController
  before_action :validate_password, only: :create

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
      redirect_to root_path, info: 'User is created and logged in successfully!'
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
      response = api_client.update_profile(user_params)
      redirect_to me_users_path, info: 'User is updated successfully!'
    rescue => e
      @error = e.message
    end
  end

  private

  def validate_password
    @error = "Password doesn't match" if params[:password] != params[:password_confirmation]
  end

  def redis_params(response)
    user = response.dig('data', 'user').slice('name', 'email', 'id')
    token = response.dig('data', 'token').slice('access_token', 'token_type', 'expires_in', 'refresh_token')
    user.merge(token)
  end

  def permitted_params
    params.permit(:email, :first_name, :last_name, :password, :date_of_birth).to_h
  end

  def user_params
    { user: permitted_params }
  end
end
