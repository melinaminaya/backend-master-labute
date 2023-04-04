# frozen_string_literal: true

class WorkerSerializer
  FIELDS = %w[
    id
    name
    email
    bio
    cpf
    phone
    address
    reject_reason
    approved
    image_path
    document_path
    document_verse_path
    proof_of_address_path
    criminal_path
    status
    rate
    blocked
    bank_digit
    bank_account
    bank_account_type
    bank_agency
    confirmation_token
  ].freeze

  def initialize(relation)
    @relation = relation
  end

  def serialize
    @relation.as_json(only: WorkerSerializer::FIELDS,
                      include: {
                        capacities: {
                          only: %i[id],
                          include: {
                            sub_category: sub_categories
                          }
                        }
                      })
  end

  def serialize_with_pagination(page)
    @relation = @relation.page(page) if page.present?

    {
      records: @relation.as_json(only: WorkerSerializer::FIELDS).uniq,
      pagination: page.present? ? pagination : nil
    }
  end

  def serialize_with_pagination_and_categories(page)
    @relation = @relation.page(page) if page.present?

    {
      records: @relation.as_json(only: WorkerSerializer::FIELDS,
                                 include: {
                                   capacities: {
                                     only: %i[id],
                                     include: {
                                       sub_category: sub_categories
                                     }
                                   }
                                 }).uniq,
      pagination: page.present? ? pagination : nil
    }
  end

  private

  def sub_categories
    {
      only: %i[id title],
      include: {
        category: categories
      }
    }
  end

  def categories
    {
      only: %i[id title]
    }
  end

  def pagination
    {
      count: Worker.count,
      current_page: @relation.current_page,
      total_pages: @relation.total_pages,
      next_page: @relation.next_page,
      prev_page: @relation.prev_page,
      limit_value: @relation.limit_value,
      current_count: @relation.count
    }
  end
end
