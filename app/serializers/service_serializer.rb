# frozen_string_literal: true

class ServiceSerializer
  FIELDS = %w[
    id title description
    images status start_date
    end_date start_time end_time
    address reject_reason
    material_support charges
  ]

  def initialize(relation)
    @relation = relation
  end

  def serialize
    @relation.as_json(only: ServiceSerializer::FIELDS,
                      include: {
                        client: { only: %i[id name cpf email] },
                        sub_categories: { only: %i[id title] },
                        proposals: proposals,
                        problems: {},
                        cancellations: {},
                        evaluations: {},
                        cupon_usage: {
                          include: { cupon: {} }
                        }
                      })
  end

  def serialize_with_pagination(page)
    @relation = @relation.page(page) if page.present?
    fields = ServiceSerializer::FIELDS.select { |field| field != 'images' }

    {
      records: @relation.as_json(only: fields),
      pagination: page.present? ? pagination : nil
    }
  end

  private

  def proposals
    {
      only: %i[price text id status reject_reason],
      include: {
        worker: { only: %i[id rate name image_path cpf] }
      }
    }
  end

  def pagination
    {
      count: Service.count,
      current_page: @relation.current_page,
      total_pages: @relation.total_pages,
      next_page: @relation.next_page,
      prev_page: @relation.prev_page,
      limit_value: @relation.limit_value,
      current_count: @relation.count
    }
  end
end
