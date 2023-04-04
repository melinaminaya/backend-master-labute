# frozen_string_literal: true

class Transaction < ApplicationRecord
  belongs_to :service

  AVAILABLE_ORDER_STATUS = %w[
    CREATED
    WAITING
    PAID
    NOT_PAID
    REVERTED
  ].freeze

  AVAILABLE_PAYMENT_STATUS = %w[
    CREATED
    WAITING
    IN_ANALYSIS
    PRE_AUTHORIZED
    AUTHORIZED
    CANCELLED
    REFUNDED
    REVERSED
    SETTLED
  ].freeze

  validates :order_status, inclusion: { in: AVAILABLE_ORDER_STATUS }, presence: true
  validates :payment_status, inclusion: { in: AVAILABLE_PAYMENT_STATUS }, presence: true
end
