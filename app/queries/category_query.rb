# frozen_string_literal: true

class CategoryQuery < BaseQuery
  def initialize(relation = Category.all)
    @relation = relation
  end
end
