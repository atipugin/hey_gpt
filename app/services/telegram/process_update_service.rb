# frozen_string_literal: true

module Telegram
  class ProcessUpdateService
    include ActsAsService

    def initialize(update:)
      @update = update
    end

    def call
      message = @update.current_message
      return failure unless message.is_a?(Telegram::Bot::Types::Message)

      ProcessMessageService.new(message:).call
    end
  end
end
