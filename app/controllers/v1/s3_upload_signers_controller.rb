# frozen_string_literal: true

module V1
  class S3UploadSignersController < BaseController
    skip_before_action :authenticate_member!, only: [:create, :create_for_unauthenticated]
    before_action :custom_authentication, except: [:create_for_unauthenticated]
    before_action :set_service, only: [:create_for_service]

    def create
      signature = S3::Signer.new(
        object: current_member || @member,
        file_name: params[:file_name],
        resource_name: params[:resource_name]
      ).generate_signature

      render_success(signature)
    rescue S3::Signer::UnknownExtensionError,
           S3::Signer::UnknownResourceError => e
      render_failure(e)
    end

    def create_for_unauthenticated
      signature = S3::Signer.new(
        file_name: params[:file_name],
        resource_name: params[:resource_name]
      ).generate_unauthenticated_signature

      render_success(signature)
    rescue S3::Signer::UnknownExtensionError,
           S3::Signer::UnknownResourceError => e
      render_failure(e)
    end

    def create_for_service
      signature = S3::Signer.new(
        object: @service,
        file_name: params[:file_name],
        resource_name: params[:resource_name]
      ).generate_signature

      render_success(signature)
    rescue S3::Signer::UnknownExtensionError,
           S3::Signer::UnknownResourceError => e
      render_failure(e)
    end

    def set_service
      @service = Service.find(params[:service_id])
    rescue ActiveRecord::RecordNotFound
      head :not_found
    end

    private

    def render_success(signature)
      render json: {
        success: true,
        signature: signature
      }
    end

    def render_failure(error)
      render json: {
        success: false,
        info: error.message
      }, status: :bad_request
    end

    def custom_authentication
      current_member.present? ? authenticate_member! : register_authentication
    end

    def register_authentication
      authenticated = authenticate_client_or_worker
      render json: { error: 'Não autorizado' }, status: :unauthorized unless authenticated
    rescue ActiveRecord::RecordNotFound
      @member = Client.find(request.headers['register-id'])
      handler = ClientHandler::Authenticator.new(@member)
      authenticated = handler.authenticate(request.headers['register-token'])
      head :not_found unless authenticated
    end

    def authenticate_client_or_worker
      authenticated = authenticate_worker || authenticate_client
      authenticated
    rescue ActiveRecord::RecordNotFound
      authenticated = authenticate_client
      authenticated
    end

    def authenticate_client
      @member = Client.find(request.headers['register-id'])
      handler = ClientHandler::Authenticator.new(@member)
      handler.authenticate(request.headers['register-token'])
    end

    def authenticate_worker
      @member = Worker.find(request.headers['register-id'])
      handler = WorkerHandler::Authenticator.new(@member)
      handler.authenticate(request.headers['register-token'])
    end
  end
end
