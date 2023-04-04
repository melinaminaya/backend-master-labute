# frozen_string_literal: true

class Document < ApplicationRecord
  WAITING_FOR_ACCEPTANCE = 'waiting_for_acceptance'
  REJECTED = 'rejected'
  ACCEPTED = 'accepted'

  AVAILABLE_STATUS = [
    WAITING_FOR_ACCEPTANCE,
    REJECTED,
    ACCEPTED
  ].freeze

  validates :status, inclusion: { in: AVAILABLE_STATUS }, presence: true

  belongs_to :worker, optional: true
  belongs_to :client, optional: true
  has_one_attached :image
end
