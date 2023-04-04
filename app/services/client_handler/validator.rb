# frozen_string_literal: true

module ClientHandler
  class Validator
    class AlreadyFinished < StandardError; end
    attr_reader :client

    def initialize(params)
      @params = params
    end

    def validate!
      find_user
      valid?
      authenticate if valid?
    end

    def as_response
      return @response = { status: :not_found } if @client.nil?

      @response = if @valid
                    { json: ClientSerializer.new(@client).serialize }
                  else
                    { json: { errors: @client.errors.full_messages }, status: :bad_request }
                  end
    end

    private

    def find_user
      @client = Client.find_by(email: @params[:email])
    end

    def authenticate
      @client.phone_validated = true
      @client.save!

      ClientHandler::Authenticator.new(@client).generate_token
    end

    def valid?
      return false if @client.nil?

      @valid = @client.token_valid?(@params[:token])
    end
  end
end
