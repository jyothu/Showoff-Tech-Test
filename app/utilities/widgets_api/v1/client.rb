require 'oj'
require 'faraday'

module WidgetsAPI
  module V1
    class Client
      include HttpStatusCodes
      include ApiExceptions

      API_ENDPOINT = 'https://showoff-rails-react-production.herokuapp.com'.freeze

      attr_reader :access_token, :token_type, :response

      def initialize(access_token: nil, token_type: nil)
        @access_token = access_token
        @token_type = token_type
      end

      def visible_widgets(search_term: nil)
        request(
          http_method: :get,
          endpoint: "api/v1/widgets/visible",
          params: { term: search_term },
        )
      end

      def user_widgets(search_term: nil)
        request(
          http_method: :get,
          endpoint: "api/v1/users/me/widgets",
          params: { term: search_term },
        )
      end

      def get_user(id)
        request(
          http_method: :get,
          endpoint: "api/v1/users/#{id}",
        )
      end

      def my_profile
        request(
          http_method: :get,
          endpoint: 'api/v1/users/me',
        )
      end

      def update_profile(params)
        request(
          http_method: :put,
          endpoint: 'api/v1/users/me',
          params: params
        )
      end

      def create_user(params)
        request(
          http_method: :post,
          endpoint: 'api/v1/users',
          params: params
        )
      end

      def authenticate(params)
        request(
          http_method: :post,
          endpoint: 'oauth/token',
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
