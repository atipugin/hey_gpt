# frozen_string_literal: true

module Telegram
  class ProcessRegularMessageService
    include ActsAsService

    def initialize(message: @message)
      @message = message
    end

    def call
      notify_about_typing
      chat = find_or_create_chat
      user = find_or_create_user
      message = find_or_create_message(chat:, user:)
      result = ask_gpt(message:)

      return result unless result.success

      respond_to_chat(chat:, text: result.data)

      success
    end

    private

    def notify_about_typing
      client.api.send_chat_action(chat_id: @message.chat.id, action: 'typing')
    end

    def find_or_create_message(chat:, user: nil)
      chat.messages.create_with(telegram_data: @message.to_compact_hash,
                                user:).find_or_create_by(telegram_id: @message.message_id)
    end

    def find_or_create_chat
      chat = Chat.find_or_initialize_by(telegram_id: @message.chat.id)
      chat.telegram_data = @message.chat.to_compact_hash
      chat.save

      chat
    end

    def find_or_create_user
      return if @message.from.blank?

      user = User.find_or_initialize_by(telegram_id: @message.from.id)
      user.telegram_data = @message.from.to_compact_hash
      user.save

      user
    end

    def ask_gpt(message:)
      OpenAI::SendChatMessageService.new(message:).call
    end

    def respond_to_chat(chat:, text:)
      response = client.api.send_message(chat_id: chat.telegram_id, text:)
      message_sent = Telegram::Bot::Types::Message.new(response['result'])
      chat.messages.create(telegram_id: message_sent.message_id, telegram_data: message_sent.to_compact_hash)
    end

    def client
      @client ||= Telegram::Bot::Client.new(ENV.fetch('TELEGRAM_BOT_TOKEN'))
    end
  end
end
