require 'oj'
require 'faraday'

module WidgetsAPI
  module V1
    class Client
      include HttpStatusCodes
      include ApiExceptions

      API_ENDPOINT = 'https://showoff-rails-react-production.herokuapp.com'.freeze
      VISIBLE_WIDGETS_ENDPOINT = 'api/v1/widgets/visible'.freeze
      USER_WIDGETS_ENDPOINT = 'api/v1/users/me/widgets'.freeze
      WIDGETS_ENDPOINT = 'api/v1/widgets'.freeze
      USER_PROFILE_ENDPOINT = 'api/v1/users/me'.freeze
      USERS_ENDPOINT = 'api/v1/users'.freeze
      OAUTH_TOKEN_ENDPOINT = 'oauth/token'.freeze
      OAUTH_REVOKE_ENDPOINT = 'oauth/revoke'.freeze
      CHANGE_PASSWORD_ENDPOINT = 'api/v1/users/me/password'.freeze
      RESET_PASSWORD_ENDPOINT = 'api/v1/users/reset_password'.freeze

      attr_reader :access_token, :token_type, :response

      def initialize(access_token: nil, token_type: nil)
        @access_token = access_token
        @token_type = token_type
      end

      def visible_widgets(search_term: nil)
        request(
          http_method: :get,
          endpoint: VISIBLE_WIDGETS_ENDPOINT,
          params: { term: search_term },
        )
      end

      def user_widgets(search_term: nil)
        request(
          http_method: :get,
          endpoint: USER_WIDGETS_ENDPOINT,
          params: { term: search_term },
        )
      end

      def create_widget(params)
        request(
          http_method: :post,
          endpoint: WIDGETS_ENDPOINT,
          params: params,
        )
      end

      def delete_widget(widget_id)
        request(
          http_method: :delete,
          endpoint: "#{WIDGETS_ENDPOINT}/#{widget_id}",
        )
      end

      def get_user(user_id)
        request(
          http_method: :get,
          endpoint: "#{USERS_ENDPOINT}/#{user_id}",
        )
      end

      def my_profile
        request(
          http_method: :get,
          endpoint: USER_PROFILE_ENDPOINT,
        )
      end

      def update_profile(params)
        request(
          http_method: :put,
          endpoint: USER_PROFILE_ENDPOINT,
          params: params
        )
      end

      def change_password(params)
        request(
          http_method: :post,
          endpoint: CHANGE_PASSWORD_ENDPOINT,
          params: params
        )
      end

      def reset_password(params)
        request(
          http_method: :post,
          endpoint: RESET_PASSWORD_ENDPOINT,
          params: params
        )
      end

      def create_user(params)
        request(
          http_method: :post,
          endpoint: USERS_ENDPOINT,
          params: params
        )
      end

      def authenticate(params)
        request(
          http_method: :post,
          endpoint: OAUTH_TOKEN_ENDPOINT,
          params: params
        )
      end

      def revoke_token(params)
        request(
          http_method: :post,
          endpoint: OAUTH_REVOKE_ENDPOINT,
          params: params
        )
      end

      def refresh_token(params)
        request(
          http_method: :post,
          endpoint: OAUTH_TOKEN_ENDPOINT,
          params: params
        )
      end

      private

      def client
        @client ||= Faraday.new(API_ENDPOINT) do |client|
          client.request :url_encoded
          client.adapter Faraday.default_adapter
          client.headers['Authorization'] = "#{token_type} #{access_token}" if access_token.present?
        end
      end

      def request(http_method:, endpoint:, params: {})
        @response = client.public_send(http_method, endpoint, client_params.merge(params))
        parsed_response = Oj.load(response.body)

        return parsed_response if response_successful?

        raise error_class, parsed_response['message']
      end

      def error_class
        case response.status
        when HTTP_BAD_REQUEST_CODE
          BadRequestError
        when HTTP_UNAUTHORIZED_CODE
          UnauthorizedError
        when HTTP_FORBIDDEN_CODE
          ForbiddenError
        when HTTP_NOT_FOUND_CODE
          NotFoundError
        when HTTP_UNPROCESSABLE_ENTITY_CODE
          UnprocessableEntityError
        else
          ApiError
        end
      end

      def response_successful?
        response.status == HTTP_OK_CODE
      end

      def client_params
        {
          client_id: ENV['CLIENT_ID'],
          client_secret: ENV['CLIENT_SECRET'],
        }
      end
    end
  end
end
