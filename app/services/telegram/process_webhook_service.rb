# frozen_string_literal: true

module Telegram
  class ProcessWebhookService
    delegate :current_message, to: :update

    def initialize(webhook:)
      @webhook = webhook
    end

    def call
      return if skip_processing?

      client.api.send_chat_action(chat_id: current_message.chat.id, action: 'typing')

      chat = Chat.find_or_initialize_by(telegram_id: current_message.chat.id)
      chat.telegram_data = current_message.chat.to_compact_hash
      chat.save

      message = chat.messages.find_or_initialize_by(telegram_id: current_message.message_id)
      message.telegram_data = current_message.to_compact_hash

      if current_message.from.present?
        user = User.find_or_initialize_by(telegram_id: current_message.from.id)
        user.telegram_data = current_message.from.to_compact_hash
        user.save

        message.user = user
      end

      message.save

      answer_from_gpt = OpenAI::SendChatMessageService.new(message:).call
      response = client.api.send_message(chat_id: chat.telegram_id, text: answer_from_gpt)
      return unless response['ok']

      message_sent = Telegram::Bot::Types::Message.new(response['result'])
      chat.messages.create(telegram_id: message_sent.message_id, telegram_data: message_sent.to_compact_hash)
    end

    private

    def skip_processing?
      current_message.text.blank?
    end

    def update
      @update ||= Telegram::Bot::Types::Update.new(@webhook)
    end

    def client
      @client ||= Telegram::Bot::Client.new(ENV.fetch('TELEGRAM_BOT_TOKEN'))
    end
  end
end
