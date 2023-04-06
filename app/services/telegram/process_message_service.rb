# frozen_string_literal: true

module Telegram
  class ProcessMessageService
    include ActsAsService

    def initialize(message:)
      @message = message
    end

    def call
      return failure(error: :no_text) if @message.text.blank?
      return handle_bot_command if bot_command?

      handle_regular_message
    end

    private

    def bot_command?
      Array(@message.entities).any? { |e| e.type == 'bot_command' }
    end

    def handle_bot_command
      ProcessBotCommandService.new(message: @message).call
    end

    def handle_regular_message
      ProcessRegularMessageService.new(message: @message).call
    end
  end
end
