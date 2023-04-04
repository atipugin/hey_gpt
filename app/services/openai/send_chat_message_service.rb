# frozen_string_literal: true

module OpenAI
  class SendChatMessageService
    def initialize(chat:, text:)
      @chat = chat
      @text = text
    end

    def call
      client = Client.new
      messages = BuildChatMessagesService.new(chat: @chat, text: @text).call
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
  end
end
