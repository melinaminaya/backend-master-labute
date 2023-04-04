# frozen_string_literal: true

class CuponPolicy
  attr_reader :current_member, :cupon

  def initialize(current_member, cupon)
    @current_member = current_member
    @cupon = cupon
  end

  def index?
    admin?
  end

  def create?
    admin?
  end

  def show?
    admin?
  end

  def exists?
    true
  end

  def update?
    admin?
  end

  def destroy?
    admin?
  end

  private

  def admin?
    current_member.class.name.eql?('Admin')
  end

  def client?
    current_member.class.name.eql?('Client')
  end
end
