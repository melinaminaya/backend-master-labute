# frozen_string_literal: true

class EvaluationPolicy
  attr_reader :current_member, :evaluation

  def initialize(current_member, evaluation)
    @current_member = current_member
    @evaluation = evaluation
  end

  def index?
    admin?
  end

  def create?
    client? || worker?
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

  def worker?
    current_member.class.name.eql?('Worker')
  end

  def client?
    current_member.class.name.eql?('Client')
  end
end
