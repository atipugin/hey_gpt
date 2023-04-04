# frozen_string_literal: true

module OpenAI
  class SendChatMessageService
    def initialize(message:)
      @message = message
    end

    def call
      client = OpenAI::Client.new
      response = client.chat(
        parameters: {
          model: 'gpt-3.5-turbo',
          messages: [{ role: 'user', content: @message }],
          temperature: 0.7
        }
      )

      # TODO: Add error handling
      response.dig('choices', 0, 'message', 'content')
    end
  end
end
