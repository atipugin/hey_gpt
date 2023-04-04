# frozen_string_literal: true

module OpenAI
  class ChatQuery
    include ActiveModel::Model

    MAX_TOKENS = 4096

    attr_accessor :chat, :text

    validates :chat, presence: true
    validates :text, length: { maximum: MAX_TOKENS }

    def model
      'gpt-3.5-turbo'
    end

    def messages
      [system_message, history_message, user_message]
    end

    def temperature
      0.7
    end

    private

    def system_message
      { role: 'system', content: 'You are a helpful assistant.' }
    end

    def history_message
      { role: 'assistant', content: [history_prefix, history_text].join }
    end

    def history_prefix
      'Our chat history: '
    end

    def history_text
      max_size = MAX_TOKENS - system_message[:content].size - history_prefix.size - text.size
      current_size = 0
      texts = []
      chat.messages.recent.each do |message|
        break if current_size + message.text.size > max_size

        current_size += message.text.size
        texts << message.text
      end

      texts.join(' ')
    end

    def user_message
      { role: 'user', content: text }
    end
  end
end
