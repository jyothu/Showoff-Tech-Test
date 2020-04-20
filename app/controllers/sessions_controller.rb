class SessionsController < ApplicationController
  def create
    begin
      response = api_client.authenticate(create_params)
      User.create(redis_params(response))
      sign_in({ 'email': permitted_params[:username] })
      redirect_to root_url, info: 'Logged in!'
    rescue => e
      @error = e.message
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end

  private

  def permitted_params
    params.permit(:username, :password).to_h
  end

  def redis_params(response)
    token = response.dig('data', 'token').slice('access_token', 'token_type', 'expires_in', 'refresh_token')
    { 'email': permitted_params[:username] }.merge(token)
  end

  def create_params
    permitted_params.merge({ grant_type: 'password' })
  end
end
