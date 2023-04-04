# frozen_string_literal: true

class Client < ApplicationRecord
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable
  include DeviseTokenAuth::Concerns::User

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

  before_validation :create_documents, on: [:create]

  validates :status, inclusion: { in: AVAILABLE_STATUS }, presence: true
  validates :cpf, uniqueness: true

  has_many :cupon_usage, dependent: :destroy
  has_many :services, dependent: :nullify
  has_many :documents, dependent: :destroy
  has_many :evaluations, dependent: :nullify
  has_one_attached :image

  def create_documents
    documents << Document.create(name: 'document')
    documents << Document.create(name: 'proof_of_address')
  end

  def token_valid?(token)
    is_valid = confirmation_token == token
    errors.add(:base, 'Token inválido para este usuário') unless is_valid
    is_valid
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

  def cpf_number
    cpf.delete('-.')
  end

  def generate_token
    ClientHandler::Authenticator.new(self).generate_token
    self.save!
  end
  # private

end
