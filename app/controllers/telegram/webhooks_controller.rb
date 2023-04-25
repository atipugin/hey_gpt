# frozen_string_literal: true

module Telegram
  class WebhooksController < ApplicationController
    before_action :verify_secret_token

    def create
      ProcessWebhookJob.perform_later(webhook_params)
      head :ok
    end

    private

    def verify_secret_token
      return if ENV.fetch('TELEGRAM_BOT_SECRET_TOKEN') == request.headers['X-Telegram-Bot-Api-Secret-Token']

      head :unauthorized
    end

    def webhook_params
      params.permit!
    end
  end
end
