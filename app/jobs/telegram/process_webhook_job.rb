# frozen_string_literal: true

module Telegram
  class ProcessWebhookJob < ApplicationJob
    def perform(webhook)
      ProcessWebhookService.new(webhook:).call
    end
  end
end
