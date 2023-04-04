# frozen_string_literal: true

class CuponUsage < ApplicationRecord
  belongs_to :service
  belongs_to :client
  belongs_to :cupon

  validates :cupon, uniqueness: { scope: :client }
end
