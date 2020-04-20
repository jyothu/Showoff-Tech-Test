module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from Faraday::ConnectionFailed, with: :no_network
    rescue_from ApiExceptions::UnauthorizedError, with: :render_422
  end

  private

  def no_network(exception)
    @exception = 'Please check your connectivity. Seems like you are not connected to internet'
    render 'layouts/no_network.html.haml', layout: 'exception_layout'
  end

  def render_422(exception)
    sign_out
    redirect_to root_path, warning: exception
  end
end