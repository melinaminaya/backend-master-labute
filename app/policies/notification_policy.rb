# frozen_string_literal: true

class NotificationPolicy
  attr_reader :current_member, :evaluation

  def initialize(current_member)
    @current_member = current_member
  end

  def send?
    admin?
  end

  private

  def admin?
    current_member.class.name.eql?('Admin')
  end
end
