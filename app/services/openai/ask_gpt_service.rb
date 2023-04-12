# frozen_string_literal: true

module OpenAI
  class AskGPTService
    include ActsAsService

    attr_reader :message

    def initialize(message:)
      @message = message
    end

    def call
      response = openai.chat(parameters: { model: 'gpt-3.5-turbo', messages: chat_messages })
      return Result.new(success?: true, data: response['choices'][0]['message']['content']) if response.ok?

      Result.new(success?: false, error: response.dig('error', 'message'), data: response['error'])
    end

    private

    def chat_messages
      [system_message, *previous_messages, last_message]
    end

    def system_message
      { role: 'system', content: 'You are a helpful assistant.' }
    end

    def previous_messages
      max_tokens = 4096
      tokens_used = Tokenizer.instance.gpt2.encode_batch([system_message[:content], message.text]).map do |e|
        e.tokens.count
      end.sum
      messages = []
      message.chat.messages.with_text.before_message(message).each do |previous_message|
        next if previous_message.bot_command?

        tokens_used += previous_message.tokens_count
        break if tokens_used > max_tokens

        messages << convert_to_chat_message(previous_message)
      end

      messages.reverse
    end

    def last_message
      convert_to_chat_message(message)
    end

    def convert_to_chat_message(message)
      { role: message.user_id? ? 'user' : 'assistant', content: message.text }
    end

    def openai
      @openai ||= OpenAI::Client.new
    end
  end
end
