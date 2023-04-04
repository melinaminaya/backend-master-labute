# frozen_string_literal: true

class WorkerQuery < BaseQuery
  def initialize(relation = Worker.all)
    @relation = relation
  end
end
