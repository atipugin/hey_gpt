# frozen_string_literal: true

module Telegram
  class WebhooksController < ApplicationController
    def create
      ProcessWebhookJob.perform_later(webhook_params)
      head :ok
    end

    private

    def webhook_params
      params.permit!
    end
  end
end
