# frozen_string_literal: true

module OpenAI
  class SendChatMessageService
    include ActsAsService

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

      if response.ok?
        data = response.dig('choices', 0, 'message', 'content')
        success(data:)
      else
        failure(error: :failed_to_ask_gpt, data: response['error'])
      end
    end

    private

    def client
      @client ||= OpenAI::Client.new
    end
  end
end
