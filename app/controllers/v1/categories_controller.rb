# frozen_string_literal: true

module V1
  class CategoriesController < BaseController
    before_action :set_category, only: %w[show update destroy]
    skip_before_action :authenticate_member!, only: %w[index show]

    def index
      search = Category.search(params[:search])
      categories = search.result
      serializer = CategorySerializer.new(categories)

      render json: serializer.serialize_with_pagination(params[:page]), status: :ok
    end

    def show
      serializer = CategorySerializer.new(@category)
      render json: serializer.serialize, status: :ok
    end

    def create
      authorize Category
      @category = Category.new(permitted_params)
      @category.save!
      serializer = CategorySerializer.new(@category)
      render json: serializer.serialize, status: :created
    rescue ActiveRecord::RecordInvalid
      render json: { errors: @category.errors.full_messages }, status: :bad_request
    end

    def update
      authorize @category
      @category.update!(permitted_params)
      head :no_content
    end

    def destroy
      authorize @category
      @category.destroy
      head :no_content
    end

    private

    def permitted_params
      params.permit(:title,
                    :image,
                    sub_categories_attributes: %i[id title image])
    end

    def set_category
      @category = Category.find(params[:id])
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
