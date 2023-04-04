# frozen_string_literal: true

module WorkerHandler
  module Helpers
    module Responses
      def as_response
        if @worker.persisted? && @worker.valid?
          { json: WorkerSerializer.new(@worker).serialize }
        else
          { json: { errors: @worker.errors.full_messages }, status: 400 }
        end
      end
    end
  end
end
