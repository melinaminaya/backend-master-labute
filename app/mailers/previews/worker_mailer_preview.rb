# frozen_string_literal: true

class WorkerMailerPreview < ActionMailer::Preview
  def welcome
    WorkerMailer.welcome(worker.id)
  end

  def proposal
    WorkerMailer.proposal(worker.id)
  end

  def service_request
    WorkerMailer.service_request(service.id)
  end

  private

  def worker
    Worker.first || FactoryBot.create(:worker)
  end

  def service
    Service.where.not(worker_id: [nil, ""]).first
  end
end
