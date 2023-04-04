# frozen_string_literal: true

module WorkerHandler
  class Authenticator
    include Helpers::Mailer
    attr_reader :member, :token

    def initialize(member)
      @member = member
    end

    def authenticate(token)
      @member.register_token == token
    end

    def generate_token
      @member.register_token = SecureRandom.base64(16)
      @member.confirmation_token = SecureRandom.hex(3)
    end

    def send_email
      send_confirmation
    end
  end
end
