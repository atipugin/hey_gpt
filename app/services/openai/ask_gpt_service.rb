# frozen_string_literal: true

module OpenAI
  class AskGPTService
    include ActsAsService

    def initialize(conversation:)
      @conversation = conversation
    end

    def call
      response = openai.chat(parameters: { model: 'gpt-3.5-turbo', messages: @conversation.to_chatgpt_messages })
      return success(data: response['choices'][0]['message']['content']) if response.ok?

      failure(error: response.dig('error', 'message'), data: response['error'])
    end

    private

    def openai
      @openai ||= OpenAI::Client.new
    end
  end
end
