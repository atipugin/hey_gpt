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

      chat = Chat.find_or_initialize_by(telegram_id: message.chat.id)
      chat.telegram_data = message.chat.to_compact_hash
      chat.save

      # TODO: Respond to user with something
      return if message.text.blank?

      chat.messages.from_user.create(text: message.text)

      gpt_response = OpenAI::SendChatMessageService.new(chat:, text: message.text).call
      chat.messages.create(text: gpt_response)
      client.api.send_message(chat_id: chat.telegram_id, text: gpt_response)
    end
  end
end
