# frozen_string_literal: true

class Cupon < ApplicationRecord
  has_many :cupon_usages, dependent: :destroy
end
