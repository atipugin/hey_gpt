# frozen_string_literal: true

module Telegram
  class ProcessTextMessageService
    include ActsAsService
    include HasTelegramBot

    def initialize(message:, chat:, user:)
      @message = message
      @chat = chat
      @user = user
    end

    def call
      message = find_or_create_message
      conversation = build_conversation_for_message(message)
      ask_gpt_result = OpenAI::AskGPTService.new(conversation:).call
      return ask_gpt_result unless ask_gpt_result.success?

      response = telegram_bot.api.send_message(chat_id: @chat.telegram_id, text: ask_gpt_result.data)
      message_sent = Telegram::Bot::Types::Message.new(response['result'])
      @chat.messages.create!(telegram_id: message_sent.message_id, telegram_data: message_sent.to_compact_hash)

      success
    end

    private

    def find_or_create_message
      @chat.messages.find_or_initialize_by(telegram_id: @message.message_id).tap do |message|
        message.telegram_data = @message.to_compact_hash
        message.user = @user
        message.save!
      end
    end

    def build_conversation_for_message(message)
      Conversation.new.tap do |conversation|
        conversation.add_user_message(message.text)

        @chat.messages.before_message(message).each do |prev_message|
          break if conversation.full?

          if prev_message.user_id?
            conversation.add_user_message(prev_message.text)
          else
            conversation.add_ai_message(prev_message.text)
          end
        end
      end
    end
  end
end
