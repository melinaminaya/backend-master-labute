# frozen_string_literal: true

module V1
  class WorkersController < BaseController
    before_action :authenticate_member!, except: %w[update_register create_register resend_code
                                                    validate_confirmation upload_image upload_file
                                                    show index]
    before_action :register_authentication, only: %w[update_register validate_confirmation]
    before_action :custom_authentication, only: %w[upload_image upload_file]

    before_action :set_worker, only: %w[show update destroy approve reject update_register]

    def index
      search = Worker.search(params[:search])
      workers = search.result
      serializer = WorkerSerializer.new(workers)

      render json: serializer.serialize_with_pagination(params[:page]), status: :ok
    end

    def categories
      search = Worker.search(params[:search])
      workers = search.result
      serializer = WorkerSerializer.new(workers)

      render json: serializer.serialize_with_pagination_and_categories(params[:page]), status: :ok
    end

    def show
      serializer = WorkerSerializer.new(@worker)
      render json: serializer.serialize, status: :ok
    end

    def create
      authorize Worker
      @worker = Worker.new(permitted_params)
      @worker.save!
      serializer = WorkerSerializer.new(@worker)
      render json: serializer.serialize, status: :created
    rescue ActiveRecord::RecordInvalid
      render json: { errors: @worker.errors.full_messages.full_messages }, status: :bad_request
    end

    def update
      authorize @worker
      @worker.capacities.delete_all if params[:capacities_attributes].present?
      @worker.update!(permitted_params)
      head :no_content
    rescue ActiveRecord::RecordInvalid
      render json: { errors: @worker.errors.full_messages.full_messages }, status: :bad_request
    end

    def destroy
      authorize @worker
      @worker.destroy
      head :no_content
    end

    def create_register
      @worker = Worker.new(create_params)
      WorkerHandler::Authenticator.new(@worker).generate_token
      @worker.save!
      WorkerHandler::Authenticator.new(@worker).send_email
      serializer = WorkerSerializer.new(@worker)
      response.set_header('register-token', @worker.register_token)
      render json: serializer.serialize, status: :created
    rescue ActiveRecord::RecordInvalid
      render json: { errors: @worker.errors.full_messages }, status: :bad_request
    end

    def update_register
      @worker = Worker.find(request.headers['register-id'])
      @worker.capacities.delete_all if @worker.capacities.present? &&
        params[:capacities_attributes].present?
      @worker.update!(update_params)
      send_welcome_email if params[:welcome]
      serializer = WorkerSerializer.new(@worker)
      render json: serializer.serialize, status: :created
    rescue ActiveRecord::RecordInvalid
      render json: { errors: @worker.errors.full_messages.full_messages }, status: :bad_request
    end

    def resend_code
      @worker = Worker.where(phone: params[:phone]).first
      raise ActiveRecord::RecordNotFound if @worker.nil?

      error = 'Usuário já cadastrado'
      render json: { errors: error }, status: :bad_request unless @worker.status == Worker::PENDING
      return unless @worker.status == Worker::PENDING

      resend_email
      render_user_as_response
    rescue ActiveRecord::RecordNotFound
      head :not_found
    end

    def upload_image
      @worker.image.attach(params[:file])
    end

    def upload_file
      document = @worker.documents.where(name: params[:name]).first
      document.image.attach(params[:file])
    end

    def validate_confirmation
      handler = WorkerHandler::Validator.new(params)
      handler.validate!
      response.set_header('registration-token', handler.worker.register_token) if handler.worker
      render handler.as_response
    rescue WorkerHandler::Validator::AlreadyFinished
      sign_in handler.user
      render json: { message: 'Usuário já cadastrado' }, status: :found
    end

    def approve
      authorize @worker
      @worker.with_lock do
        @worker.update!(status: Worker::ACCEPTED)
        send_approval_notification
      end
      head :no_content
    end

    def reject
      authorize @worker
      @worker.with_lock do
        @worker.update!(status: Worker::REJECTED, reject_reason: params[:reason])
        send_reject_notification
      end
      head :no_content
    end

    private

    def permitted_params
      params.permit(:name, :image_path, :document_path, :bio,
                    :proof_of_address_path, :criminal_path, :document_verse_path,
                    :email, :cpf, :status, :phone, :registration_id, :bank_account_type,
                    :password, :password_confirmation, :bank_digit, :bank_account, :bank_agency,
                    address: {},
                    capacities_attributes: %i[
                      sub_category_id
                      _destroy
                      id
                    ])
    end

    def update_params
      params.permit(:image_path, :document_path, :document_verse_path,
                    :proof_of_address_path, :phone, :criminal_path, :status, :registration_id,
                    :bank_digit, :bank_account, :bank_agency, :bank_account_type,
                    address: {},
                    capacities_attributes: %i[
                      sub_category_id
                      _destroy
                      worker_id
                      id
                    ])
    end

    def create_params
      params.permit(:name,
                    :email,
                    :cpf, :phone,
                    :password,
                    :password_confirmation)
    end

    def set_worker
      @worker = Worker.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      head :not_found
    end

    def custom_authentication
      current_member.present? ? authenticate_member! : register_authentication
    end

    def register_authentication
      @worker = Worker.find(request.headers['register-id'])
      handler = WorkerHandler::Authenticator.new(@worker)
      authenticated = handler.authenticate(request.headers['register-token'])
      return render json: { error: 'Não autorizado' }, status: :unauthorized unless authenticated
    rescue ActiveRecord::RecordNotFound
      head :not_found
    end

    def resend_email
      WorkerHandler::Authenticator.new(@worker).generate_token
      @worker.save!
      WorkerHandler::Authenticator.new(@worker).send_email
    end

    def render_user_as_response
      serializer = WorkerSerializer.new(@worker)
      response.set_header('register-token', @worker.register_token)
      render json: serializer.serialize, status: :ok
    end

    def send_approval_notification
      notification_text = {
        title: 'Seu cadastro foi aprovado!',
        body: 'Entre e busque primeiro serviço'
      }
      notification_data = { type: 'profile' }
      id = @worker.registration_id
      Notifier::WorkerJob.perform_later(notification_text, notification_data, [id]) if id.present?
    end

    def send_reject_notification
      notification_text = {
        title: 'Seu cadastro foi rejeitado!',
        body: @worker.reject_reason
      }
      notification_data = { type: 'profile' }
      id = @worker.registration_id
      Notifier::WorkerJob.perform_later(notification_text, notification_data, [id]) if id.present?
    end

    def send_welcome_email
      WorkerMailer.welcome(@worker.id).deliver_now
    end

    alias pundit_user current_member
  end
end
