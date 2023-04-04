# frozen_string_literal: true

module V1
  class ServicesController < BaseController
    before_action :set_service, except: %w[index create worker_services worker_requested_services
                                           refuse_charge]
    skip_before_action :authenticate_member!, only: %w[index show]

    def index
      search = Service.search(params[:search])
      services = search.result
      serializer = ServiceSerializer.new(services)

      render json: serializer.serialize_with_pagination(params[:page]), status: :ok
    end

    def show
      authorize @service
      serializer = ServiceSerializer.new(@service)
      render json: serializer.serialize, status: :ok
    end

    def create
      authorize Service
      @service = Service.new(permitted_params)
      @service.client = current_member
      @service.save!
      serializer = ServiceSerializer.new(@service)
      render json: serializer.serialize, status: :created
    rescue ActiveRecord::RecordInvalid
      render json: { errors: @service.errors.full_messages }, status: :bad_request
    end

    def update
      authorize @service
      @service.update!(permitted_params)
      head :no_content
    rescue ActiveRecord::RecordInvalid
      render json: { errors: @service.errors.full_messages }, status: :bad_request
    end

    def destroy
      authorize @service
      @service.destroy
      head :no_content
    end

    def approve
      authorize @service
      @service.with_lock do
        @service.update!(status: Service::APPROVED, approved: true)
        send_worker_notification
      end
      head :no_content
    end

    def worker_services
      services = current_member.proposals.map(&:service)
      valid_services = services.select do |service|
        if service.accepted_proposal.present?
          service.accepted_proposal.worker_id == current_member.id
        else
          true
        end
      end
      serialize_services(valid_services)
    end

    def worker_requested_services
      search = current_member.services.search(status_not_in:
        [Service::WAITING_APPROVAL, Service::REJECTED])
      services = search.result
      serialize_services(services)
    end

    def reject
      authorize @service
      @service.with_lock do
        reason = params[:reject_reason]
        @service.update!(
          status: Service::REJECTED,
          approved: false,
          reject_reason: reason
        )
      end
      head :no_content
    end

    def finish
      authorize @service
      @service.with_lock do
        @service.update!(status: Service::FINISHED)
        send_evaluate_service_notification
      end
      head :no_content
    end

    def sign
      authorize @service
      @service.with_lock do
        @service.update!(status: Service::WAITING_PAYMENT)
      end
      head :no_content
    end

    def charge
      authorize @service
      @service.with_lock do
        @service.charges << { price: params[:price], text: params[:text] }
        @service.status = Service::WAITING_PAYMENT
        @service.save!
      end
      head :no_content
    end

    def refuse_charge
      authorize @service
      @service.with_lock do
        @service.charges.last[:refused] = true
        @service.status = Service::IN_PROGRESS
        @service.save!
      end
      head :no_content
    end

    def chat_notification
      from = params[:from]
      notification_text = {
        title: "Nova mensagem no serviço #{@service.title}",
        body: params[:message]
      }
      notification_data = { type: 'service', service_id: @service.id }
      if from == 'client'
        send_notification_worker(notification_text, notification_data)
      elsif from == 'worker'
        send_notification_client(notification_text, notification_data)
      end
    end

    private

    def permitted_params
      params.permit(:title, :description,
                    :image, :status,
                    :end_date, :start_date,
                    :end_time, :start_time,
                    :material_support,
                    :reject_reason, :worker_id,
                    address: {},
                    sub_category_ids: [],
                    images: %i[path name default highlight],
                    charges: %i[price text])
    end

    def set_service
      @service = Service.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      head :not_found
    end

    def serialize_services(services)
      serializer = ServiceSerializer.new(services)

      render json: serializer.serialize_with_pagination(params[:page]), status: :ok
    end

    def send_worker_notification
      send_sub_categories_notification
      send_worker_push
      send_worker_request_email
      send_worker_proposal_sms
      send_worker_proposal_email
    end

    def send_worker_request_email
      return if @service[:worker_id].nil?
      WorkerMailer.service_request(@service.id).deliver_later
    end

    def send_worker_proposal_email
      return if @service[:worker_id].present?
      workers_for_sub_categories.each do |worker|
        WorkerMailer.proposal(worker).deliver_later
      end
    end

    def send_worker_proposal_sms
      return if @service[:worker_id].present?
      WorkerMailer.multiple_proposal_sms(workers_for_sub_categories).deliver_later
    end

    def workers_for_sub_categories
      return @workers if @workers.present?

      sub_category_ids = @service.sub_categories.pluck(:id)
      @workers = Worker.includes(:sub_categories).where(sub_categories: { id: sub_category_ids })
      @workers.compact
    end

    def send_sub_categories_notification
      return if @service[:worker_id].present?

      notification_text = {
        title: 'Novo serviço na sua área de atuação!',
        body: 'Entre e faça uma proposta'
      }
      notification_data = { type: 'service', service_id: @service.id }

      ids = registration_ids_for_sub_categories
      Notifier::WorkerJob.perform_later(notification_text, notification_data, ids) if ids.any?
    end

    def registration_ids_for_sub_categories
      sub_category_ids = @service.sub_categories.pluck(:id)
      workers = Worker.includes(:sub_categories).where(sub_categories: { id: sub_category_ids })
      workers.pluck(:registration_id).compact
    end

    def send_worker_push
      return if @service[:worker_id].nil?

      notification_text = {
        title: 'Você recebeu uma solicitação de serviço!',
        body: 'Entre e faça uma proposta'
      }
      notification_data = { type: 'service', service_id: @service.id }
      id = Worker.find(@service[:worker_id]).registration_id
      Notifier::WorkerJob.perform_later(notification_text, notification_data, [id]) if id.present?
    end

    def send_evaluate_service_notification
      notification_text = {
        title: "O serviço #{@service.title} acabou",
        body: 'Entre e avalie o serviço'
      }
      notification_data = { type: 'service', service_id: @service.id }
      send_notification_client(notification_text, notification_data)
      send_notification_worker(notification_text, notification_data)
    end

    def send_notification_client(notification_text, notification_data)
      id = Client.find(@service[:client_id]).registration_id
      Notifier::ClientJob.perform_later(notification_text, notification_data, [id]) if id.present?
    end

    def send_notification_worker(notification_text, notification_data)
      id = Worker.find(@service.accepted_proposal[:worker_id]).registration_id
      Notifier::WorkerJob.perform_later(notification_text, notification_data, [id]) if id.present?
    end
    alias pundit_user current_member
  end
end
