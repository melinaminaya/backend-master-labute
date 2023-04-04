# frozen_string_literal: true

class ProposalPolicy
  attr_reader :current_member, :proposal

  def initialize(current_member, proposal)
    @current_member = current_member
    @proposal = proposal
  end

  def index?
    admin?
  end

  def create?
    worker?
  end

  def show?
    admin? || client? || worker?
  end

  def update?
    admin? || client? || worker?
  end

  def approve?
    admin?
  end

  def reject?
    admin?
  end

  def accept?
    client?
  end

  def destroy?
    worker? && self?
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
    current_member.id.eql?(@proposal.worker.id)
  end
end
