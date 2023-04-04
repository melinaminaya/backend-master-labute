# frozen_string_literal: true

class ClientQuery < BaseQuery
  def initialize(relation = Client.all)
    @relation = relation
  end
end
