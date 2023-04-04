# frozen_string_literal: true

FactoryBot.define do
  factory :sub_category do
    sequence(:title) { Faker::HowIMetYourMother.high_five }
  end
end
