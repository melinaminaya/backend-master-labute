# frozen_string_literal: true

class Capacity < ApplicationRecord
  belongs_to :sub_category
  belongs_to :worker

  validates :worker, presence: true
  validates :sub_category, presence: true

  validates :sub_category, uniqueness: { scope: :worker }
end
