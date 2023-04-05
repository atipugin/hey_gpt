# frozen_string_literal: true

module OpenAI
  class SendChatMessageService
    def initialize(message:)
      @message = message
    end

    def call
      messages = BuildChatMessagesService.new(message: @message).call
      response = client.chat(
        parameters: {
          model: 'gpt-3.5-turbo',
          messages:,
          temperature: 0.7
        }
      )

      unless response.ok?
        error = response['error']
        Sentry.capture_message(error['message'], extra: error.except('message'))
      end

      # TODO: Add error handling
      response.dig('choices', 0, 'message', 'content')
    end

    private

    def client
      @client ||= OpenAI::Client.new
    end
  end
end
