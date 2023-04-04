# frozen_string_literal: true

module OpenAI
  class SendChatMessageService
    def initialize(chat:, text:)
      @chat = chat
      @text = text
    end

    def call
      query = ChatQuery.new(chat: @chat, text: @text)
      return if query.invalid?

      client = Client.new
      response = client.chat(
        parameters: {
          model: query.model,
          messages: query.messages,
          temperature: query.temperature
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
