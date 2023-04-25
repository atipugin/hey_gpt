# frozen_string_literal: true

module Telegram
  class ProcessWebhookService
    include ActsAsService

    def initialize(webhook:)
      @webhook = webhook
    end

    def call
      update = Telegram::Bot::Types::Update.new(@webhook)
      result = ProcessUpdateService.new(update:).call
      Sentry.capture_message(result.error, extra: result.data) if result.error

      result
    end
  end
end
