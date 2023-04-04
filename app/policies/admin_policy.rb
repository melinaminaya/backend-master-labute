# frozen_string_literal: true

class AdminPolicy
  attr_reader :current_member, :admin

  def initialize(current_member, admin)
    @current_member = current_member
    @admin = admin
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

  def update?
    admin?
  end

  def destroy?
    admin? && !self?
  end

  private

  def admin?
    current_member.class.name.eql?('Admin')
  end

  def self?
    current_member.id.eql?(admin.id)
  end
end
