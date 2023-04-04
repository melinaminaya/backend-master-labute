# frozen_string_literal: true

module V1
  module Auth
    module Workers
      class TokenValidationsController < DeviseTokenAuth::TokenValidationsController
        protected

        def render_validate_token_success
          render json: {
            success: true,
            data: WorkerSerializer.new(@resource).serialize
          }
        end
      end
    end
  end
end
