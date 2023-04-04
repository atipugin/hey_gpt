# frozen_string_literal: true

module Telegram
  class ProcessWebhookService
    def initialize(webhook:)
      @webhook = webhook
    end

    def call
      client = Bot::Client.new(ENV.fetch('TELEGRAM_BOT_TOKEN'))
      update = Bot::Types::Update.new(@webhook)
      message = update.current_message
      client.api.send_chat_action(chat_id: message.chat.id, action: 'typing')

      user = User.find_or_initialize_by(telegram_id: message.from.id)
      user.telegram_data = message.from.to_compact_hash
      user.save

      chat_response = OpenAI::SendChatMessageService.new(message: message.text).call
      client.api.send_message(chat_id: message.chat.id, text: chat_response)
    end
  end
end
