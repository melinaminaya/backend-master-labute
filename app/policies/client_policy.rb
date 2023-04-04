# frozen_string_literal: true

class ClientPolicy
  attr_reader :current_member, :client

  def initialize(current_member, client)
    @current_member = current_member
    @client = client
  end

  def index?
    admin?
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
    admin? || client?
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

  def client?
    current_member.class.name.eql?('Client')
  end

  def self?
    current_member.id.eql?(client.id)
  end
end
