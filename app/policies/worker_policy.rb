# frozen_string_literal: true

class WorkerPolicy
  attr_reader :current_member, :worker

  def initialize(current_member, worker)
    @current_member = current_member
    @worker = worker
  end

  def index?
    true
  end

  def create?
    admin?
  end

  def approve?
    admin?
  end

  def reject?
    admin?
  end

  def show?
    true
  end

  def update?
    admin? || self?
  end

  def destroy?
    admin? || self?
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
