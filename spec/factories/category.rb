# frozen_string_literal: true

FactoryBot.define do
  factory :category do
    sequence(:title) { Faker::HowIMetYourMother.catch_phrase }

    transient do
      sub_categories_count 3
    end

    after :create do |category, evaluator|
      category.sub_categories = build_list(:sub_category, evaluator.sub_categories_count, category: category)
      category.save!
    end
  end
end
