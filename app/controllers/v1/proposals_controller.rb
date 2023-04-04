# frozen_string_literal: true

module V1
  class ProposalsController < BaseController
    before_action :set_proposal, only: %w[show update destroy accept reject approve]
    skip_before_action :authenticate_member!, only: %w[services]

    def index
      search = Proposal.search(params[:search])
      proposals = search.result
      serializer = ProposalSerializer.new(proposals)

      render json: serializer.serialize_with_pagination(params[:page]), status: :ok
    end

    def show
      authorize @proposal
      serializer = ProposalSerializer.new(@proposal)
      render json: serializer.serialize, status: :ok
    end

    def create
      authorize Proposal
      @proposal = Proposal.new(permitted_params)
      @proposal.worker = current_member
      @proposal.save!
      serializer = ProposalSerializer.new(@proposal)
      render json: serializer.serialize, status: :created
    rescue ActiveRecord::RecordInvalid
      render json: { errors: @proposal.errors.full_messages }, status: :bad_request
    end

    def update
      authorize @proposal
      @proposal.update!(permitted_params)
      head :no_content
    rescue ActiveRecord::RecordInvalid
      render json: { errors: @proposal.errors.full_messages }, status: :bad_request
    end

    def destroy
      authorize @proposal
      @proposal.destroy
      head :no_content
    end

    def approve
      authorize @proposal
      @proposal.with_lock do
        @proposal.update!(status: Proposal::APPROVED)
      end
      head :no_content
    end

    def reject
      authorize @proposal
      @proposal.with_lock do
        reason = params[:reject_reason]
        @proposal.update!(
          status: Proposal::REJECTED,
          reject_reason: reason
        )
      end
      head :no_content
    end

    def accept
      authorize @proposal
      @proposal.with_lock do
        @proposal.update!(status: Proposal::ACCEPTED)
        @proposal.service.update!(status: Service::WAITING_SIGNATURES)
      end
      send_client_notification
      head :no_content
    end

    def services
      search = Proposal.search(params[:search])
      proposals = search.result
      services = Service.find(proposals.pluck(:service_id))
      serializer = ServiceSerializer.new(services)

      render json: serializer.serialize_with_pagination(params[:page]), status: :ok
    end

    private

    def permitted_params
      params.permit(:price,
                    :text,
                    :reject_reason,
                    :status,
                    :service_id)
    end

    def set_proposal
      @proposal = Proposal.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      head :not_found
    end

    def send_client_notification
      client = @proposal.service.client
      return if client.nil?

      notification_text = {
        title: 'Você recebeu uma nova proposta!',
        body: "Entre e confira o serviço #{@proposal.service.title}"
      }
      notification_data = { type: 'service', service_id: @proposal.service.id }
      id = client.registration_id
      Notifier::ClientJob.perform_later(notification_text, notification_data, [id]) if id.present?
    end

    alias pundit_user current_member
  end
end
