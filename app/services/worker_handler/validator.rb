# frozen_string_literal: true

module WorkerHandler
  class Validator
    class AlreadyFinished < StandardError; end
    attr_reader :worker

    def initialize(params)
      @params = params
    end

    def validate!
      find_user
      valid?
      authenticate if valid?
    end

    def as_response
      return @response = { status: :not_found } if @worker.nil?

      @response = if @valid
                    { json: WorkerSerializer.new(@worker).serialize }
                  else
                    { json: { errors: @worker.errors.full_messages }, status: :bad_request }
                  end
    end

    private

    def find_user
      @worker = Worker.find_by(email: @params[:email])
    end

    def authenticate
      raise AlreadyFinished if @worker.status == Worker::WAITING_FOR_ACCEPTANCE

      WorkerHandler::Authenticator.new(@worker).generate_token
    end

    def valid?
      return false if @worker.nil?

      @valid = @worker.token_valid?(@params[:token])
    end
  end
end
