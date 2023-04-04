# frozen_string_literal: true

module V1
  class ClientsController < BaseController
    before_action :authenticate_member!, except: %w[update_register create_register resend_code
                                                    validate_confirmation upload_image upload_file
                                                    index]
    before_action :register_authentication, only: %w[update_register]
    before_action :custom_authentication, only: %w[upload_image upload_file]

    before_action :set_client, only: %w[show update destroy approve reject update_register]

    def index
      search = Client.search(params[:search])
      clients = search.result
      serializer = ClientSerializer.new(clients)

      render json: serializer.serialize_with_pagination(params[:page]), status: :ok
    end

    def show
      authorize @client
      serializer = ClientSerializer.new(@client)
      render json: serializer.serialize, status: :ok
    end

    def create
      authorize Client
      @client = Client.new(permitted_params)
      @client.save!
      serializer = ClientSerializer.new(@client)
      render json: serializer.serialize, status: :created
    rescue ActiveRecord::RecordInvalid
      render json: { errors: @client.errors.full_messages }, status: :bad_request
    end

    def update
      authorize @client
      @client.update!(permitted_params)
      head :no_content
    end

    def destroy
      authorize @client
      @client.destroy
      head :no_content
    end

    def create_register
      @client = Client.new(create_params)
      @client.save!
      serializer = ClientSerializer.new(@client)
      response.set_header('register-token', @client.register_token)
      render json: serializer.serialize, status: :created
    rescue ActiveRecord::RecordInvalid
      render json: { errors: @client.errors.full_messages }, status: :bad_request
    end

    def update_register
      @client = Client.find(request.headers['register-id'])
      @client.update!(update_params)
      serializer = ClientSerializer.new(@client)
      send_welcome_email if params[:welcome]
      render json: serializer.serialize, status: :created
    rescue ActiveRecord::RecordInvalid
      render json: { errors: @client.errors.full_messages }, status: :bad_request
    end

    def resend_code
      @clients = Client.where(phone: params[:phone])
      raise ActiveRecord::RecordNotFound if @clients.empty?

      token = Array.new(6) { rand(0...9) }.join('')
      @clients.update(confirmation_token: token)

      resend_sms(params[:phone], token)
      head :no_content
    rescue ActiveRecord::RecordNotFound
      head :not_found
    end

    def upload_image
      @client.image.attach(params[:file])
    end

    def upload_file
      document = @client.documents.where(name: params[:name]).first
      document.image.attach(params[:file])
    end

    def validate_confirmation
      handler = ClientHandler::Validator.new(params)
      handler.validate!
      response.set_header('registration-token', handler.client.register_token) if handler.client
      render handler.as_response
    end

    def approve
      authorize @client
      @client.with_lock do
        @client.update!(status: Client::ACCEPTED)
        send_approval_notification
      end
      head :no_content
    end

    def reject
      authorize @client
      @client.with_lock do
        @client.update!(status: Client::REJECTED, reject_reason: params[:reason])
        send_reject_notification
      end
      head :no_content
    end

    private

    def permitted_params
      params.permit(:name, :image_path, :document_path, :bio,
                    :proof_of_address_path, :criminal_path, :document_verse_path,
                    :email, :cpf, :status, :image, :registration_id,
                    :is_approved, :password, :phone,
                    :password_confirmation)
    end

    def update_params
      params.permit(:image_path,
                    :proof_of_address_path,
                    :criminal_path,
                    :document_path,
                    :document_verse_path,
                    :registration_id,
                    :status, :phone)
    end

    def create_params
      params.permit(:name,
                    :email,
                    :cpf, :phone,
                    :password,
                    :password_confirmation)
    end

    def set_client
      @client = Client.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      head :not_found
    end

    def pagination(model, relation)
      {
        count: model.count,
        current_page: relation.current_page,
        total_pages: relation.total_pages,
        next_page: relation.next_page,
        prev_page: relation.prev_page
      }
    end

    def custom_authentication
      current_member.present? ? authenticate_member! : register_authentication
    end

    def register_authentication
      @client = Client.find(request.headers['register-id'])
      handler = ClientHandler::Authenticator.new(@client)
      authenticated = handler.authenticate(request.headers['register-token'])
      return render json: { error: 'Não autorizado' }, status: :unauthorized unless authenticated
    rescue ActiveRecord::RecordNotFound
      head :not_found
    end

    def resend_sms(phone, confirmation_token)
      sns = Aws::SNS::Client.new(region: ENV['AWS_REGION'])
      message = "#{ENV['RECOVER_PASSWORD_MESSAGE']} #{confirmation_token}"

      sns.publish(phone_number: normalized_phone(phone), message: message)
    end

    def normalized_phone(phone)
      "+55#{phone[1]}#{phone[2]}#{phone.split(' ').second.delete('-')}"
    end

    def render_user_as_response
      serializer = ClientSerializer.new(@client)
      response.set_header('register-token', @client.register_token)
      render json: serializer.serialize, status: :ok
    end

    def send_approval_notification
      notification_text = {
        title: 'Seu cadastro foi aprovado!',
        body: 'Entre e crie seu primeiro serviço'
      }
      notification_data = { type: 'profile' }
      id = @client.registration_id
      Notifier::ClientJob.perform_later(notification_text, notification_data, [id]) if id.present?
    end

    def send_reject_notification
      notification_text = {
        title: 'Seu cadastro foi rejeitado!',
        body: @client.reject_reason
      }
      notification_data = { type: 'profile' }
      id = @client.registration_id
      Notifier::ClientJob.perform_later(notification_text, notification_data, [id]) if id.present?
    end

    def send_welcome_email
      ClientMailer.welcome(@client.id).deliver_later
    end

    alias pundit_user current_member
  end
end
