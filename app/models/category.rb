# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :sub_categories, dependent: :destroy

  accepts_nested_attributes_for :sub_categories, allow_destroy: true
end
