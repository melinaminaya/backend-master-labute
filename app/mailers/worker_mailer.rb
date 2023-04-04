# frozen_string_literal: true

class WorkerMailer < ApplicationMailer
  layout 'layouts/mailer'
  default template_path: "mailers/#{name.underscore}"

  def welcome(id)
    @worker = Worker.find(id)

    mail(to: @worker.email,
         from: ENV['EMAIL_FROM'],
         subject: I18n.t('mailers.worker_mailer.welcome.subject'))
  end

  def multiple_proposal(workers)
    workers.each { |worker| proposal(worker).deliver_later }
  end

  def proposal(worker)
    @worker = worker
    @url = 'https://pro.labute.com.br/search'

    mail(to: @worker.email,
         from: ENV['EMAIL_FROM'],
         subject: I18n.t('mailers.worker_mailer.proposal.subject'))
  end

  def multiple_proposal_sms(workers)
    workers.each { |worker| proposal_sms(worker) }
  end

  def proposal_sms(worker)
    @worker = worker

    message = "Olá, #{@worker.name}! #{ENV['PROPOSAL_MESSAGE']}"
    send_sms(@worker.normalized_phone, message)
  end

  def service_request(id)
    @service = Service.find(id)
    @worker = @service.worker
    @url = "https://pro.labute.com.br/services/#{@service.id}"

    mail(to: @worker.email,
         from: ENV['EMAIL_FROM'],
         subject: I18n.t('mailers.worker_mailer.service_request.subject'))
  end

  def confirmation(id)
    user = Worker.find(id)

    send_confirmation_sms(user)
  end

  def send_confirmation_sms(user)
    message = "#{ENV['RECOVER_PASSWORD_MESSAGE']} #{user.confirmation_token}"

    send_sms(user.normalized_phone, message)
  end

  def send_sms(phone, message)
    sns = Aws::SNS::Client.new(region: ENV['AWS_REGION'])

    sns.publish(phone_number: phone, message: message)
  end
end
