# frozen_string_literal: true

module V1
  module Auth
    module Clients
      class SessionsController < DeviseTokenAuth::SessionsController
        # rubocop:disable all
        # This method is a directly override from devise token auth create_token
        def create
          # Check
          field = (resource_params.keys.map(&:to_sym) & resource_class.authentication_keys).first

          @resource = nil
          if field
            q_value = get_case_insensitive_field_from_resource_params(field)

            @resource = find_resource(field, q_value)
          end

          if @resource && valid_params?(field, q_value) && (!@resource.respond_to?(:active_for_authentication?) || @resource.active_for_authentication?)
            valid_password = @resource.valid_password?(resource_params[:password]) || social_login
            if (@resource.respond_to?(:valid_for_authentication?) && !@resource.valid_for_authentication? { valid_password }) || !valid_password
              return render_create_error_bad_credentials
            end
            @client_id, @token = @resource.create_token
            @resource.save

            sign_in(:user, @resource, store: false, bypass: false)

            yield @resource if block_given?

            render_create_success
          elsif @resource && !(!@resource.respond_to?(:active_for_authentication?) || @resource.active_for_authentication?)
            if @resource.respond_to?(:locked_at) && @resource.locked_at
              render_create_error_account_locked
            else
              render_create_error_not_confirmed
            end
          else
            render_create_error_bad_credentials
          end
        end
        # rubocop:enable all

        protected

        def render_create_success
          render json: {
            status: 'success',
            client: ClientSerializer.new(@resource).serialize,
            info: I18n.t('devise.sessions.signed_in'),
          }
        end

        def render_create_error_bad_credentials
          render json: {
            status: 'error',
            errors: [I18n.t('devise_token_auth.sessions.bad_credentials')]
          }, status: :unauthorized
        end

        def social_login
          social_nws = %w[
            google
            facebook
            apple
          ]

          params[:social].present? && social_nws.include?(params[:social])
        end
      end
    end
  end
end
