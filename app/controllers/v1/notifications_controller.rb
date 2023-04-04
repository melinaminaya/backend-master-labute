# frozen_string_literal: true

module V1
  class NotificationsController < BaseController
    skip_before_action :authenticate_member!, only: %w[notify]

    def notify
      @notification = {}
      @notification[:title] = params[:title]
      @notification[:body] = params[:body]
      if params[:app] == 'client'
        Notifier::ClientJob.perform_later(@notification)
      else
        Notifier::WorkerJob.perform_later(@notification)
      end
      head :ok
    end
  end
end
