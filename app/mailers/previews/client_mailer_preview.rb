# frozen_string_literal: true

class ClientMailerPreview < ActionMailer::Preview
  def welcome
    ClientMailer.welcome(client.id)
  end

  def payment_accepted
    ClientMailer.payment_accepted(service.id)
  end

  def payment_rejected
    ClientMailer.payment_rejected(service.id)
  end

  private

  def client
    Client.first || FactoryBot.create(:client)
  end

  def service
    services = Service.where.not(client_id: [nil, '']).where(status: Service::IN_PROGRESS)
    services.select { |service| service.accepted_proposal.worker.present? }.first
  end
end
