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
      Rails.logger.error(result.error) unless result.success

      result
    end
  end
end
