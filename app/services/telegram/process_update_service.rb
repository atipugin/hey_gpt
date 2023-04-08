# frozen_string_literal: true

module Telegram
  class ProcessUpdateService
    include ActsAsService

    attr_reader :update

    delegate :current_message, to: :update

    def initialize(update:)
      @update = update
    end

    def call
      chat = find_or_create_chat
      user = find_or_create_user
      message = find_or_create_message(chat:, user:)

      ProcessMessageService.new(message:).call
    end

    private

    def find_or_create_chat
      chat = Chat.find_or_initialize_by(telegram_id: current_message.chat.id)
      chat.telegram_data = current_message.chat.to_compact_hash
      chat.save!

      chat
    end

    def find_or_create_user
      return if current_message.from.blank?

      user = User.find_or_initialize_by(telegram_id: current_message.from.id)
      user.telegram_data = current_message.from.to_compact_hash
      user.save!

      user
    end

    def find_or_create_message(chat:, user: nil)
      chat
        .messages
        .create_with(telegram_data: current_message.to_compact_hash, user:)
        .find_or_create_by!(telegram_id: current_message.message_id)
    end
  end
end
