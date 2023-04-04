# frozen_string_literal: true

module V1
  class EvaluationsController < BaseController
    before_action :set_evaluation, only: %w[show update destroy]
    before_action :set_service, only: %w[create]
    skip_before_action :authenticate_member!, only: %w[index show]

    def index
      search = Evaluation.search(params[:search])
      evaluations = search.result
      serializer = EvaluationSerializer.new(evaluations)

      render json: serializer.serialize_with_pagination(params[:page]), status: :ok
    end

    def show
      serializer = EvaluationSerializer.new(@evaluation)
      render json: serializer.serialize, status: :ok
    end

    def create
      authorize Evaluation
      @evaluation = Evaluation.new(permitted_params)
      calculate_rate
      @evaluation.save!
      serializer = EvaluationSerializer.new(@evaluation)
      render json: serializer.serialize, status: :created
    rescue ActiveRecord::RecordInvalid
      render json: { errors: @evaluation.errors.full_messages }, status: :bad_request
    end

    def update
      authorize @evaluation
      @evaluation.update!(permitted_params)
      head :no_content
    end

    def destroy
      authorize @evaluation
      @evaluation.destroy
      head :no_content
    end

    private

    def permitted_params
      params.permit(:rate, :service_id)
    end

    def set_evaluation
      @evaluation = Evaluation.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      head :not_found
    end

    def set_service
      @service = Service.find(params[:service_id])
    rescue ActiveRecord::RecordNotFound
      head :not_found
    end

    def calculate_rate
      current_member.class.name.eql?('Client') ? calculate_worker_rate : calculate_client_rate
    end

    def calculate_worker_rate
      worker = @service.accepted_proposal.worker
      evaluations_count = worker.evaluations.count
      total_rate = worker.rate * evaluations_count
      evaluations_count += 1
      worker.rate = (total_rate + @evaluation.rate) / evaluations_count
      worker.save!
      @evaluation.worker_id = worker.id
    end

    def calculate_client_rate
      client = @service.client
      evaluations_count = client.evaluations.count
      total_rate = client.rate * evaluations_count
      evaluations_count += 1
      client.rate = (total_rate + @evaluation.rate) / evaluations_count
      client.save!
      @evaluation.client_id = client.id
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

    alias pundit_user current_member
  end
end
