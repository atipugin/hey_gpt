# frozen_string_literal: true

module Telegram
  class ProcessBotCommandService
    include ActsAsService
    include HasTelegramBot

    def initialize(message:, chat:, user:)
      @message = message
      @chat = chat
      @user = user
    end

    def call
      case bot_command
      when '/start'
        handle_start_command
      when '/reset'
        handle_reset_command
      when '/stats'
        handle_stats_command
      else
        failure
      end
    end

    private

    def bot_command
      entity = @message.entities.find { |e| e.type == 'bot_command' && e.offset.zero? }
      return unless entity

      @message.text[entity.offset, entity.length]
    end

    def handle_start_command
      @chat.unblock if @chat.blocked?
      reply_to(chat: @chat, text: t('start.welcome'))

      success
    end

    def handle_reset_command
      @chat.messages.delete_all
      reply_to(chat: @chat, text: t('reset.done'))

      success
    end

    def handle_stats_command
      return failure unless @user.admin?

      users_count = User.count
      messages_count = Message.count
      reply_to(chat: @chat, text: t('stats.text', users_count:, messages_count:))

      success
    end
  end
end
