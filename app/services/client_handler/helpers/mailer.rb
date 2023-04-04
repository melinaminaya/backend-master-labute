# frozen_string_literal: true

module ClientHandler
  module Helpers
    module Mailer
      def send_confirmation
        return unless @member.persisted? && @member.valid?

        ClientMailer.confirmation(@member.id).deliver_now
      end
    end
  end
end
