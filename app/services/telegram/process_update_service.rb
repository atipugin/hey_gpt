# frozen_string_literal: true

module Telegram
  class ProcessUpdateService
    include ActsAsService

    delegate :current_message, to: :@update

    def initialize(update:)
      @update = update
    end

    def call
      case current_message
      when Telegram::Bot::Types::Message
        handle_message
      else
        handle_unsupported_message
      end
    end

    private

    def handle_message
      ProcessMessageService.new(message: current_message).call
    end

    def handle_unsupported_message
      failure(error: :unsupported_message)
    end
  end
end
