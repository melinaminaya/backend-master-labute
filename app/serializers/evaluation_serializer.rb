# frozen_string_literal: true

class EvaluationSerializer
  FIELDS = %w[
    id
    rate
    created_at
  ].freeze

  def initialize(relation)
    @relation = relation
  end

  def serialize
    @relation.as_json(only: EvaluationSerializer::FIELDS,
                      include: {
                        service: service,
                        client: client,
                        worker: worker
                      })
  end

  def serialize_with_pagination(page)
    @relation = @relation.page(page) if page.present?

    {
      records: @relation.as_json(only: EvaluationSerializer::FIELDS),
      pagination: page.present? ? pagination : nil
    }
  end

  private

  def pagination
    {
      count: Evaluation.count,
      current_page: @relation.current_page,
      total_pages: @relation.total_pages,
      next_page: @relation.next_page,
      prev_page: @relation.prev_page,
      limit_value: @relation.limit_value,
      current_count: @relation.count
    }
  end

  def service
    {
      only: %i[id title description]
    }
  end

  def client
    {
      only: %i[id name cpf email]
    }
  end

  def worker
    {
      only: %i[id name cpf email]
    }
  end
end
