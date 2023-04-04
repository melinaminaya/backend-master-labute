# frozen_string_literal: true

module V1
  class CuponUsagesController < BaseController
    before_action :set_cupon_usage, only: %w[show update destroy]
    skip_before_action :authenticate_member!, only: %w[index show]

    def index
      search = CuponUsage.search(params[:search])
      cupon_usages = search.result
      serializer = CuponUsageSerializer.new(cupon_usages)

      render json: serializer.serialize_with_pagination(params[:page]), status: :ok
    end

    def show
      serializer = CuponUsageSerializer.new(@cupon_usage)
      render json: serializer.serialize, status: :ok
    end

    def create
      authorize CuponUsage
      @cupon_usage = CuponUsage.new(permitted_params)
      cupon = Cupon.find_by(name: params[:cupon])
      raise ActiveRecord::RecordNotFound if cupon.nil?

      @cupon_usage.cupon = cupon
      @cupon_usage.save!
      serializer = CuponUsageSerializer.new(@cupon)
      render json: serializer.serialize, status: :created
    rescue ActiveRecord::RecordInvalid
      render json: { errors: @cupon_usage.errors.full_messages }, status: :bad_request
    rescue ActiveRecord::RecordNotFound
      render json: { errors: ['Cupóm inválido'] }, status: :not_found
    end

    def update
      authorize @cupon_usage
      @cupon_usage.update!(permitted_params)
      head :no_content
    end

    def destroy
      authorize @cupon_usage
      @cupon_usage.destroy
      head :no_content
    end

    private

    def permitted_params
      params.permit(:client_id, :service_id)
    end

    def set_cupon_usage
      @cupon_usage = CuponUsage.find(params[:id])
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
