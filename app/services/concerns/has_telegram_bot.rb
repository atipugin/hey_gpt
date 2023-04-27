# frozen_string_literal: true

module HasTelegramBot
  def reply_to(chat:, text:)
    return if chat.blocked?

    telegram_bot.api.send_message(chat_id: chat.telegram_id, text:)
  rescue Telegram::Bot::Exceptions::ResponseError => e
    case e.error_code
    when 403
      chat.block and return
    else
      raise
    end
  end

  def telegram_bot
    @telegram_bot ||= Telegram::Bot::Client.new(ENV.fetch('TELEGRAM_BOT_TOKEN'))
  end
end
