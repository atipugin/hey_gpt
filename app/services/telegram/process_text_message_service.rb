# frozen_string_literal: true

module Telegram
  class ProcessTextMessageService
    include ActsAsService
    include HasTelegramBot

    attr_reader :message

    def initialize(message:)
      @message = message
    end

    def call
      ask_gpt_result = OpenAI::AskGPTService.new(message:).call
      return ask_gpt_result if ask_gpt_result.error

      response = telegram_bot.api.send_message(chat_id: message.chat.telegram_id, text: ask_gpt_result.data)
      message_sent = Telegram::Bot::Types::Message.new(response['result'])
      message.chat.messages.create!(telegram_id: message_sent.message_id, telegram_data: message_sent.to_compact_hash)

      Result.new(success?: true)
    end
  end
end
