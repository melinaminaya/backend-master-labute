# frozen_string_literal: true

require 'cpf_cnpj'

FactoryBot.define do
  name = Faker::Friends.character

  factory :worker do
    provider 'email'
    name { name }
    password 'ggc@1234'
    cpf { CPF.generate }
    email { "#{name.downcase.tr(' ', '_')}@ggclabs.com.br" }
  end
end
