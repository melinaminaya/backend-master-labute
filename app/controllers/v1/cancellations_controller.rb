# frozen_string_literal: true

module V1
  class CancellationsController < BaseController
    before_action :set_cancellation, only: %w[show update destroy]
    skip_before_action :authenticate_member!, only: %w[index show]

    def index
      search = Cancellation.search(params[:search])
      cancellations = search.result
      serializer = CancellationSerializer.new(cancellations)

      render json: serializer.serialize_with_pagination(params[:page]), status: :ok
    end

    def show
      serializer = CancellationSerializer.new(@cancellation)
      render json: serializer.serialize, status: :ok
    end

    def create
      authorize Cancellation
      @cancellation = Cancellation.new(permitted_params)
      @cancellation.save!
      serializer = CancellationSerializer.new(@cancellation)
      render json: serializer.serialize, status: :created
    rescue ActiveRecord::RecordInvalid
      render json: { errors: @cancellation.errors.full_messages }, status: :bad_request
    end

    def update
      authorize @cancellation
      @cancellation.update!(permitted_params)
      head :no_content
    end

    def destroy
      authorize @cancellation
      @cancellation.destroy
      head :no_content
    end

    private

    def permitted_params
      params.permit(:description, :service_id, :response)
    end

    def set_cancellation
      @cancellation = Cancellation.find(params[:id])
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

    alias pundit_user current_member
  end
end
