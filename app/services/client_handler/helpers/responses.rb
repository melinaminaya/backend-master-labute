# frozen_string_literal: true

module ClientHandler
  module Helpers
    module Responses
      def as_response
        if @client.persisted? && @client.valid?
          { json: ClientSerializer.new(@client).serialize }
        else
          { json: { errors: @client.errors.full_messages }, status: 400 }
        end
      end
    end
  end
end
