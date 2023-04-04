# frozen_string_literal: true

class CancellationPolicy
  attr_reader :current_member, :cancellation

  def initialize(current_member, cancellation)
    @current_member = current_member
    @cancellation = cancellation
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
