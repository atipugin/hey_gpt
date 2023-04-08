# frozen_string_literal: true

module Telegram
  class ProcessMessageService
    include ActsAsService
    include HasTelegramBot

    attr_reader :message

    def initialize(message:)
      @message = message
    end

    def call
      send_typing_action

      return handle_unsupported_message if unsupported_message?
      return handle_bot_command if message.bot_command?

      handle_text_message
    end

    private

    def send_typing_action
      telegram_bot.api.send_chat_action(chat_id: message.chat.telegram_id, action: 'typing')
    end

    def unsupported_message?
      message.text.blank?
    end

    def handle_unsupported_message
      telegram_bot.api.send_message(chat_id: message.chat.telegram_id, text: t('unsupported_message'))

      Result.new(success?: true)
    end

    def handle_bot_command
      ProcessBotCommandService.new(message:).call
    end

    def handle_text_message
      ProcessTextMessageService.new(message:).call
    end
  end
end
