# frozen_string_literal: true

module V1
  module Auth
    module Workers
      class SessionsController < DeviseTokenAuth::SessionsController
        protected

        def render_create_success
          render json: {
            status: 'success',
            worker: WorkerSerializer.new(@resource).serialize,
            info: I18n.t('devise.sessions.signed_in')
          }
        end

        def render_create_error_bad_credentials
          render json: {
            status: 'error',
            errors: [I18n.t('devise_token_auth.sessions.bad_credentials')]
          }, status: :unauthorized
        end
      end
    end
  end
end
