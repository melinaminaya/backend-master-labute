# frozen_string_literal: true

module V1
  class SubCategoriesController < BaseController
    before_action :set_sub_category, only: %w[show destroy update]
    skip_before_action :authenticate_member!, only: %w[index show create update destroy]

    def index
      search = SubCategory.search(params[:search])
      sub_categories = search.result
      serializer = SubCategorySerializer.new(sub_categories)

      render json: serializer.serialize_with_pagination(params[:page]), status: :ok
    end

    def show
      serializer = SubCategorySerializer.new(@sub_category)
      render json: serializer.serialize, status: :ok
    end

    def create
      authorize SubCategory
      @sub_category = SubCategory.new(permitted_params)
      @sub_category.save!
      serializer = SubCategorySerializer.new(@sub_category)
      render json: serializer.serialize, status: :created
    rescue ActiveRecord::RecordInvalid
      render json: { errors: @sub_category.errors.full_messages }, status: :bad_request
    end

    def update
      authorize @sub_category
      @sub_category.update!(permitted_params)
      head :no_content
    end

    def destroy
      authorize @sub_category
      @sub_category.destroy
      head :no_content
    end

    private

    def permitted_params
      params.permit(:title,
                    :image,
                    :category_id)
    end

    def set_sub_category
      @sub_category = SubCategory.find(params[:id])
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
