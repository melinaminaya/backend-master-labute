# frozen_string_literal: true

class TransactionPolicy
  attr_reader :current_member, :transaction

  def initialize(current_member, transaction)
    @current_member = current_member
    @transaction = transaction
  end

  def index?
    admin?
  end

  def create?
    client?
  end

  def charge?
    client?
  end

  def authenticate?
    client?
  end

  def show?
    admin? || client?
  end

  def update?
    admin? || client?
  end

  private

  def admin?
    current_member.class.name.eql?('Admin')
  end

  def worker?
    current_member.class.name.eql?('Worker')
  end

  def client?
    current_member.class.name.eql?('Client')
  end
end
