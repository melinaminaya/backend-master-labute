# frozen_string_literal: true

class SubCategory < ApplicationRecord
  belongs_to :category
  has_many :capacities, dependent: :destroy
  has_many :workers, through: :capacities
  has_and_belongs_to_many :services
end
