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
      client.api.send_message(chat_id: message.chat.id, text: message.text)
    end
  end
end
