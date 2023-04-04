# frozen_string_literal: true

class ServicePolicy
  attr_reader :current_member, :service

  def initialize(current_member, service)
    @current_member = current_member
    @service = service
  end

  def index?
    admin? || worker?
  end

  def create?
    client?
  end

  def show?
    true
  end

  def update?
    admin? || client?
  end

  def approve?
    admin?
  end

  def reject?
    admin?
  end

  def finish?
    client?
  end

  def destroy?
    client? || admin?
  end

  def sign?
    client?
  end

  def charge?
    worker?
  end

  def refuse_charge?
    client?
  end

  def worker_services?
    worker?
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

  def self?
    current_member.id.eql?(worker.id)
  end
end
