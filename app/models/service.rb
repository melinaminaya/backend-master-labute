# frozen_string_literal: true

class Service < ApplicationRecord
  WAITING_APPROVAL = 'waiting_for_approval'
  APPROVED = 'approved'
  REJECTED = 'rejected'
  WAITING_SIGNATURES = 'waiting_for_signatures'
  WAITING_PAYMENT = 'waiting_for_payment'
  IN_PROGRESS = 'in_progress'
  FINISHED = 'finished'

  AVAILABLE_STATUS = [
    WAITING_APPROVAL,
    APPROVED,
    REJECTED,
    WAITING_SIGNATURES,
    WAITING_PAYMENT,
    IN_PROGRESS,
    FINISHED
  ].freeze

  belongs_to :client
  belongs_to :worker, optional: true
  has_one :cupon_usage, dependent: :destroy
  has_many :proposals, dependent: :destroy
  has_many :transactions, dependent: :nullify
  has_many :problems, dependent: :nullify
  has_many :cancellations, dependent: :nullify
  has_many :evaluations, dependent: :nullify
  has_and_belongs_to_many :sub_categories

  validates :status, inclusion: { in: AVAILABLE_STATUS }, presence: true

  def accepted_proposal
    proposals.where(status: Proposal::ACCEPTED).first
  end
end
