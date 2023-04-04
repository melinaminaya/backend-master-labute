# frozen_string_literal: true

class ClientMailer < ApplicationMailer
  layout 'layouts/mailer'
  default template_path: "mailers/#{name.underscore}"

  def welcome(id)
    @client = Client.find(id)

    mail(to: @client.email,
         from: ENV['EMAIL_FROM'],
         subject: I18n.t('mailers.client_mailer.welcome.subject'))
  end

  def payment_accepted(id)
    @service = Service.find(id)
    @subcategory = @service.sub_categories.first
    @category = @subcategory.category
    @client = @service.client
    @date = @service.start_date
    @url = "https://app.labute.com.br/services/#{@service.id}"
    @worker = @service.accepted_proposal.worker
    @worker_image = @worker.image_path || "#{ENV['MAILER_ASSETS_HOST']}/profile.png"
    @price = price.round(2, half: :down)
    @installments = installments

    mail(to: @client.email,
         from: ENV['EMAIL_FROM'],
         subject: I18n.t('mailers.client_mailer.payment_accepted.subject'))
  end

  def payment_rejected(id)
    @service = Service.find(id)
    @client = @service.client
    @date = @service.start_date
    @url = "https://app.labute.com.br/services/#{@service.id}"

    mail(to: @client.email,
         from: ENV['EMAIL_FROM'],
         subject: I18n.t('mailers.client_mailer.payment_rejected.subject'))
  end

  def price
    base_price = @service.accepted_proposal.price * 1.15
    discount = @service.cupon_usage.present? && @service.cupon_usage.cupon.percentage
    discount ? (base_price * (1 - (discount / 100))) : base_price
  end

  def installments
    create_api
    payment_id = @service.transactions.last.payment_id
    payment = @wirecard_api.payment.show(payment_id)
    payment[:installment_count]
  end

  def create_api
    auth = Moip2::Auth::Basic.new(ENV['WIRECARD_TOKEN'], ENV['WIRECARD_SECRET'])
    client = Moip2::Client.new(Rails.env.production? ? :production : :sandbox, auth)
    # client = Moip2::Client.new(:production, auth) # For production tests on dev environments only
    @wirecard_api = Moip2::Api.new(client)
  end

  def confirmation(id)
    user = Client.find(id)

    send_sms(user)
  end

  private

  def send_sms(user)
    sns = Aws::SNS::Client.new(region: ENV['AWS_REGION'])
    message = "#{ENV['RECOVER_PASSWORD_MESSAGE']} #{user.confirmation_token}"

    sns.publish(phone_number: user.normalized_phone, message: message)
  end
end
