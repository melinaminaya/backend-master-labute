# frozen_string_literal: true

class ClientSerializer
  FIELDS = %w[
    id
    name
    email
    bio
    phone
    cpf
    approved
    image_path
    document_path
    document_verse_path
    reject_reason
    proof_of_address_path
    criminal_path
    created_at
    updated_at
    status
    rate
    blocked
    confirmation_token
    phone_validated
  ].freeze

  def initialize(relation)
    @relation = relation
  end

  def serialize
    @relation.as_json(only: ClientSerializer::FIELDS)
  end

  def serialize_with_pagination(page)
    @relation = @relation.page(page) if page.present?

    {
      records: @relation.as_json(only: ClientSerializer::FIELDS),
      pagination: page.present? ? pagination : nil
    }
  end

  private

  def pagination
    {
      count: Client.count,
      current_page: @relation.current_page,
      total_pages: @relation.total_pages,
      next_page: @relation.next_page,
      prev_page: @relation.prev_page,
      limit_value: @relation.limit_value,
      current_count: @relation.count
    }
  end
end
