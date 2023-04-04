# frozen_string_literal: true

class TransactionSerializer
  FIELDS = %w[
    id
    status
    code
    created_at
  ].freeze

  def initialize(relation)
    @relation = relation
  end

  def serialize
    @relation.as_json(only: TransactionSerializer::FIELDS,
                      include: {
                        service: service
                      })
  end

  def serialize_with_pagination(page)
    @relation = @relation.page(page) if page.present?

    {
      records: @relation.as_json(only: TransactionSerializer::FIELDS,
                                 include: {
                                   service: service
                                 }),
      pagination: page.present? ? pagination : nil
    }
  end

  private

  def pagination
    {
      count: Transaction.count,
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
      },
      methods: %i[accepted_proposal]
    }
  end

  def client
    {
      only: %i[id name cpf email]
    }
  end
end
