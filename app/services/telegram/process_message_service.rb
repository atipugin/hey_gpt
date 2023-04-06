# frozen_string_literal: true

module Telegram
  class ProcessMessageService
    include ActsAsService

    def initialize(message:)
      @message = message
    end

    def call
      return success if skip_processing?
      return handle_bot_command if bot_command?

      handle_regular_message
    end

    private

    def skip_processing?
      @message.text.blank?
    end

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
