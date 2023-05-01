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
      send_typing_action

      return too_many_messages if @user.too_many_messages?

      message = find_or_create_message
      @user.messages_count.increment if message.previously_new_record?
      conversation = build_conversation_for_message(message)
      ask_gpt_result = OpenAI::AskGPTService.new(conversation:).call
      return ask_gpt_result unless ask_gpt_result.success?

      responses = reply_to(chat: @chat, text: ask_gpt_result.data)
      return failure if responses.blank?

      responses.each do |response|
        message_sent = Telegram::Bot::Types::Message.new(response['result'])
        @chat.messages.create!(telegram_id: message_sent.message_id, telegram_data: message_sent.to_compact_hash)
      end

      success
    end

    private

    def send_typing_action
      telegram_bot.api.send_chat_action(chat_id: @chat.telegram_id, action: 'typing')
    end

    def too_many_messages
      reply_to(
        chat: @chat,
        text: t('too_many_messages', limit: @user.messages_limit, referral_url: @user.referral_url),
        disable_web_page_preview: true
      )

      failure
    end

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
