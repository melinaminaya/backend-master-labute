# frozen_string_literal: true

module WorkerHandler
  module Helpers
    module Mailer
      def send_confirmation
        return unless @member.persisted? && @member.valid?

        WorkerMailer.confirmation(@member.id).deliver_now
      end
    end
  end
end
