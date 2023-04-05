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
      {
        role: 'system',
        content: <<~TXT.squish
          You are a helpful assistant.
          If you have chat history with user, consider using it to answer user questions.
        TXT
      }
    end

    def history_message
      return if @chat.messages.empty?

      # Figure out how many tokens for history we have
      history_template = <<~TXT.squish
        This is chat history as JSON array: %s.
        Messages are sorted by time in descending order.
        Message that starts with "U:" belongs to user.
        Message that starts with "A:" belongs to you.
      TXT
      encodings = tokenizer.encode_batch([system_message[:content], history_template, @text])
      tokens_left = MAX_TOKENS - encodings.map { |e| e.tokens.size }.sum

      # Populate `entries` until we reach the limit
      entries = []
      tokens_count = 0
      @chat.messages.recent.each do |message|
        entry = "#{message.from_user? ? 'U' : 'A'}: #{message.text}"
        tokens_count += tokenizer.encode(entry).tokens.size
        break if tokens_count > tokens_left

        entries << entry
      end

      return if entries.blank?

      { role: 'assistant', content: format(history_template, entries.to_json) }
    end

    def user_message
      { role: 'user', content: @text }
    end

    def tokenizer
      Tokenizer.instance.gpt2
    end
  end
end
