# frozen_string_literal: true

module Telegram
  class ProcessMessageService
    include ActsAsService
    include HasTelegramBot

    def initialize(message:)
      @message = message
    end

    def call
      chat = find_or_create_chat
      user = find_or_create_user

      if bot_command?
        ProcessBotCommandService.new(message: @message, chat:, user:).call
      elsif text_message?
        ProcessTextMessageService.new(message: @message, chat:, user:).call
      else
        message_not_supported
      end
    end

    private

    def find_or_create_chat
      Chat.find_or_initialize_by(telegram_id: @message.chat.id).tap do |chat|
        chat.telegram_data = @message.chat.to_compact_hash
        chat.save!
      end
    end

    def find_or_create_user
      return unless @message.from

      User.find_or_initialize_by(telegram_id: @message.from.id).tap do |user|
        user.telegram_data = @message.from.to_compact_hash
        user.save!
      end
    end

    def bot_command?
      @message.entities&.any? { |e| e.type == 'bot_command' && e.offset.zero? }
    end

    def text_message?
      @message.text.present?
    end

    def message_not_supported
      telegram_bot.api.send_message(chat_id: @message.chat.id, text: t('message_not_supported'))

      failure
    end
  end
end
