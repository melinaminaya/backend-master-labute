# frozen_string_literal: true

class Proposal < ApplicationRecord
  belongs_to :service
  belongs_to :worker

  WAITING_APPROVAL = 'waiting_for_approval'
  APPROVED = 'approved'
  REJECTED = 'rejected'
  ACCEPTED = 'accepted'

  AVAILABLE_STATUS = [
    WAITING_APPROVAL,
    APPROVED,
    REJECTED,
    ACCEPTED
  ].freeze

  validates :status, inclusion: { in: AVAILABLE_STATUS }, presence: true
end
