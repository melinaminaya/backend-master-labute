# frozen_string_literal: true

module V1
  class ProblemsController < BaseController
    before_action :set_problem, only: %w[show update destroy]
    skip_before_action :authenticate_member!, only: %w[index show]

    def index
      search = Problem.search(params[:search])
      problems = search.result
      serializer = ProblemSerializer.new(problems)

      render json: serializer.serialize_with_pagination(params[:page]), status: :ok
    end

    def show
      serializer = ProblemSerializer.new(@problem)
      render json: serializer.serialize, status: :ok
    end

    def create
      authorize Problem
      @problem = Problem.new(permitted_params)
      @problem.save!
      serializer = ProblemSerializer.new(@problem)
      render json: serializer.serialize, status: :created
    rescue ActiveRecord::RecordInvalid
      render json: { errors: @problem.errors.full_messages }, status: :bad_request
    end

    def update
      authorize @problem
      @problem.update!(permitted_params)
      head :no_content
    end

    def destroy
      authorize @problem
      @problem.destroy
      head :no_content
    end

    private

    def permitted_params
      params.permit(:description, :service_id, :response)
    end

    def set_problem
      @problem = Problem.find(params[:id])
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
