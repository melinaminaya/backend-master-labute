# frozen_string_literal: true

class ProblemPolicy
  attr_reader :current_member, :problem

  def initialize(current_member, problem)
    @current_member = current_member
    @problem = problem
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
