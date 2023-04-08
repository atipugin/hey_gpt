# frozen_string_literal: true

module HasTelegramBot
  def telegram_bot
    @telegram_bot ||= Telegram::Bot::Client.new(ENV.fetch('TELEGRAM_BOT_TOKEN'))
  end
end
