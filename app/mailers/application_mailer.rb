# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "LABUTE <#{ENV['EMAIL_FROM']}>"
  layout 'mailer'
end
