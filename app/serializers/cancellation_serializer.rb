# frozen_string_literal: true

class CancellationSerializer
  FIELDS = %w[
    id
    description
    response
    created_at
  ].freeze

  def initialize(relation)
    @relation = relation
  end

  def serialize
    @relation.as_json(only: CancellationSerializer::FIELDS,
                      include: {
                        service: service
                      })
  end

  def serialize_with_pagination(page)
    @relation = @relation.page(page) if page.present?

    {
      records: @relation.as_json(only: CancellationSerializer::FIELDS),
      pagination: page.present? ? pagination : nil
    }
  end

  private

  def pagination
    {
      count: Cancellation.count,
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
      only: %i[id title description],
      include: {
        client: client
      }
    }
  end

  def client
    {
      only: %i[id name cpf email]
    }
  end
end
