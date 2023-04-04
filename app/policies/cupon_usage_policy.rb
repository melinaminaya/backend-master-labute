# frozen_string_literal: true

class CuponUsagePolicy
  attr_reader :current_member, :cupon_usage

  def initialize(current_member, cupon_usage)
    @current_member = current_member
    @cupon_usage = cupon_usage
  end

  def index?
    admin?
  end

  def create?
    client?
  end

  def show?
    admin?
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
