# frozen_string_literal: true

require 'cpf_cnpj'

FactoryBot.define do
  name = Faker::HowIMetYourMother.character

  factory :client do
    provider 'email'
    name { name }
    password 'ggc@1234'
    cpf { CPF.generate }
    email { "#{name.downcase.tr(' ', '_')}@ggclabs.com.br" }
  end
end
