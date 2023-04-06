# frozen_string_literal: true

module Telegram
  class ProcessBotCommandService
    include ActsAsService

    def initialize(message:)
      @message = message
    end

    def call
      case command
      when '/start'
        handle_start_command
      when '/reset'
        handle_reset_command
      when '/stats'
        handle_stats_command
      else
        handle_unsupported_command
      end
    end

    private

    def command
      entity = @message.entities.find { |e| e.type == 'bot_command' }
      @message.text[entity.offset, entity.length]
    end

    def handle_start_command
      success
    end

    def handle_reset_command
      chat_id = @message.chat.id
      chat = Chat.find_by(telegram_id: chat_id)
      chat.messages.destroy_all if chat.present?
      client.api.send_message(chat_id:, text: 'All done!')

      success
    end

    def handle_stats_command
      # TODO: Check if user is allowed to see stats

      text = <<~TXT
        Users: #{User.count}
        Chats: #{Chat.count}
        Messages: #{Message.count}
      TXT
      client.api.send_message(chat_id: @message.chat.id, text:)

      success
    end

    def handle_unsupported_command
      failure(error: :unsupported_command)
    end

    def client
      @client ||= Telegram::Bot::Client.new(ENV.fetch('TELEGRAM_BOT_TOKEN'))
    end
  end
end
