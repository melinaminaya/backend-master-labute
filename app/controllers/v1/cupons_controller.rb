# frozen_string_literal: true

module V1
  class CuponsController < BaseController
    before_action :set_cupon, only: %w[show update destroy]
    skip_before_action :authenticate_member!, only: %w[index show]

    def index
      search = Cupon.search(params[:search])
      cupons = search.result
      serializer = CuponSerializer.new(cupons)

      render json: serializer.serialize_with_pagination(params[:page]), status: :ok
    end

    def show
      serializer = CuponSerializer.new(@cupon)
      render json: serializer.serialize, status: :ok
    end

    def exists
      @cupon = Cupon.find_by(name: params[:name])
      serializer = CuponSerializer.new(@cupon)
      render json: serializer.serialize, status: :ok
    end

    def create
      authorize Cupon
      @cupon = Cupon.new(permitted_params)
      @cupon.save!
      serializer = CuponSerializer.new(@cupon)
      render json: serializer.serialize, status: :created
    rescue ActiveRecord::RecordInvalid
      render json: { errors: @cupon.errors.full_messages }, status: :bad_request
    end

    def update
      authorize @cupon
      @cupon.update!(permitted_params)
      head :no_content
    end

    def destroy
      authorize @cupon
      @cupon.destroy
      head :no_content
    end

    private

    def permitted_params
      params.permit(:name, :percentage)
    end

    def set_cupon
      @cupon = Cupon.find(params[:id])
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
