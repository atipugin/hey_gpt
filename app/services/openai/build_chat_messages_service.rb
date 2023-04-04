# frozen_string_literal: true

require 'tokenizer'

module OpenAI
  class BuildChatMessagesService
    MAX_TOKENS = 4096

    def initialize(chat:, text:)
      @chat = chat
      @text = text
    end

    def call
      [system_message, history_message, user_message].compact
    end

    private

    def system_message
      { role: 'system', content: 'You are a helpful assistant.' }
    end

    def history_message
      return if @chat.messages.empty?

      # Figure out how many tokens for history we have
      prefix = 'Our chat history as JSON: '
      encodings = tokenizer.encode_batch([system_message[:content], @text, prefix])
      tokens_left = MAX_TOKENS - encodings.map { |e| e.tokens.size }.sum

      # Populate `entries` until we reach the limit
      entries = []
      tokens_count = 0
      @chat.messages.recent.each do |message|
        tokens_count += tokenizer.encode(message.text).tokens.size
        break if tokens_count > tokens_left

        entries << message.text
      end

      return if entries.blank?

      { role: 'assistant', content: prefix + entries.to_json }
    end

    def user_message
      { role: 'user', content: @text }
    end

    def tokenizer
      Tokenizer.instance.gpt2
    end
  end
end
