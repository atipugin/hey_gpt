# frozen_string_literal: true

module Telegram
  class ProcessBotCommandService
    include ActsAsService
    include HasTelegramBot

    attr_reader :message

    def initialize(message:)
      @message = message
    end

    def call
      case message.bot_command
      when '/start' then handle_start_command
      when '/reset' then handle_reset_command
      when '/stats' then handle_stats_command
      else handle_unsupported_command
      end
    end

    private

    def handle_start_command
      telegram_bot.api.send_message(chat_id: message.chat.telegram_id, text: t('start.welcome'))

      Result.new(success?: true)
    end

    def handle_reset_command
      message.chat.messages.destroy_all
      telegram_bot.api.send_message(chat_id: message.chat.telegram_id, text: t('reset.done'))

      Result.new(success?: true)
    end

    def handle_stats_command
      return handle_unsupported_command unless message.user.admin?

      users_count = User.count
      messages_count = Message.count
      telegram_bot.api.send_message(chat_id: message.chat.telegram_id,
                                    text: t('stats.text', users_count:,
                                                          messages_count:))

      Result.new(success?: true)
    end

    def handle_unsupported_command
      Result.new(success?: false)
    end
  end
end
