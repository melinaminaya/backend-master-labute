# frozen_string_literal: true

class CategoryPolicy
  attr_reader :current_member, :category

  def initialize(current_member, category)
    @current_member = current_member
    @category = category
  end

  def index?
    true
  end

  def create?
    admin?
  end

  def show?
    true
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
