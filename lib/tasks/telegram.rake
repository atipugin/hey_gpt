# frozen_string_literal: true

namespace :telegram do
  task :set_webhook, %i[url] => :environment do |_, args|
    url = args[:url]
    return if url.blank?

    client = Telegram::Bot::Client.new(ENV.fetch('TELEGRAM_BOT_TOKEN'))
    response = client.api.set_webhook(url:, allowed_updates: %w[message])
    # TODO: Handle error response
    puts response
  end

  task delete_webhook: :environment do
    client = Telegram::Bot::Client.new(ENV.fetch('TELEGRAM_BOT_TOKEN'))
    response = client.api.delete_webhook
    # TODO: Handle error response
    puts response
  end
end
