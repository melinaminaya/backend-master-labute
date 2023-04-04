# frozen_string_literal: true

class SubCategoryPolicy
  attr_reader :current_member, :sub_category

  def initialize(current_member, sub_category)
    @current_member = current_member
    @sub_category = sub_category
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
end
