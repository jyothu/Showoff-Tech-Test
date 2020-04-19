class UsersController < ApplicationController
  before_action :validate_password, only: :create

  def show
    @user = api_client.get_user(params[:id])
  end

  def create
    return if @error.present?

    begin
      response = api_client.create_user(create_params)
      User.create(redis_params(response))
      sign_in(permitted_params.slice(:email))
      redirect_to root_path, info: 'User is created and logged in successfully!'
    rescue => e
      @error = e.message
    end
  end

  private

  def validate_password
    @error = "Password doesn't match" if params[:password] != params[:password_confirmation]
  end

  def redis_params(response)
    user = response['data']['user'].slice('name', 'email', 'id')
    token = response['data']['token'].slice('access_token', 'token_type', 'expires_in', 'refresh_token')
    user.merge(token)
  end

  def permitted_params
    params.permit(:email, :first_name, :last_name, :password).to_h
  end

  def create_params
    { user: permitted_params }
  end
end
