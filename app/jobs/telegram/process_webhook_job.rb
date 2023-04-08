# frozen_string_literal: true

module Telegram
  class ProcessWebhookJob < ApplicationJob
    retry_on Net::ReadTimeout, Net::OpenTimeout, wait: :exponentially_longer

    def perform(webhook)
      ProcessWebhookService.new(webhook:).call
    end
  end
end
