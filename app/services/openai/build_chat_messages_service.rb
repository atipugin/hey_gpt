# frozen_string_literal: true

require 'tokenizer'

module OpenAI
  class BuildChatMessagesService
    MAX_TOKENS = 4096

    def initialize(message:)
      @message = message
    end

    def call
      previous_messages.prepend(system_message).append(current_message)
    end

    private

    def previous_messages
      tokens_count = 0
      tokens_left =
        MAX_TOKENS -
        tokenizer.encode_batch(
          [system_message[:content], current_message[:content]]
        ).map { |e| e.tokens.count }.sum

      messages = []
      @message.chat.messages.where('telegram_id < ?', @message.telegram_id).order(telegram_id: :desc).each do |message|
        tokens_count += tokenizer.encode(message.text).tokens.count
        break if tokens_count > tokens_left

        messages << message
      end

      messages.reverse.map do |message|
        { role: (message.user_id? ? 'user' : 'assistant'), content: message.text }
      end
    end

    def system_message
      { role: 'system', content: 'You are a helpful assistant.' }
    end

    def current_message
      { role: 'user', content: @message.text }
    end

    def tokenizer
      Tokenizer.instance.gpt2
    end
  end
end
