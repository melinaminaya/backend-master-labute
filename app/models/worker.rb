# frozen_string_literal: true

class Worker < ApplicationRecord
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :validatable
  include DeviseTokenAuth::Concerns::User

  has_many :proposals, dependent: :destroy
  has_many :capacities, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :sub_categories, through: :capacities
  has_many :evaluations, dependent: :nullify
  has_many :services, dependent: :nullify
  has_one_attached :image

  before_validation :create_documents, on: [:create]
  validates :cpf, uniqueness: true, presence: true

  PENDING = 'pending'
  WAITING_FOR_ACCEPTANCE = 'waiting_for_acceptance'
  REJECTED = 'rejected'
  ACCEPTED = 'accepted'

  AVAILABLE_STATUS = [
    PENDING,
    WAITING_FOR_ACCEPTANCE,
    REJECTED,
    ACCEPTED
  ].freeze

  accepts_nested_attributes_for :capacities, allow_destroy: true

  def token_valid?(token)
    is_valid = confirmation_token == token
    errors.add(:base, 'Token inválido para este usuário') unless is_valid
    is_valid
  end

  def create_documents
    documents << Document.create(name: 'document')
    documents << Document.create(name: 'proof_of_address')
    documents << Document.create(name: 'criminal')
  end

  def area_code
    "#{phone[1]}#{phone[2]}"
  end

  def phone_number
    phone.split(' ').second.delete('-')
  end

  def normalized_phone
    "+55#{area_code}#{phone_number}"
  end
end
