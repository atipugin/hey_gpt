# frozen_string_literal: true

class Conversation
  Item = Struct.new(:type, :text, :tokens_count)

  TYPE_USER = 'user'
  TYPE_AI = 'ai'
  TYPE_TO_CHATGPT_ROLES = { TYPE_USER => 'user', TYPE_AI => 'assistant' }.freeze
  MAX_TOKENS = 4096

  def initialize
    @items = []
  end

  def add_user_message(text)
    add_message(TYPE_USER, text)
  end

  def add_ai_message(text)
    add_message(TYPE_AI, text)
  end

  def full?
    overall_tokens_count > MAX_TOKENS
  end

  def to_chatgpt_messages
    @items.map { |i| { role: TYPE_TO_CHATGPT_ROLES[i.type], content: i.text } }.reverse
  end

  private

  def add_message(type, text)
    tokens_count = Tokenizer.instance.gpt2.encode(text).tokens.count
    return if overall_tokens_count + tokens_count > MAX_TOKENS

    @items << Item.new(type, text, tokens_count)
  end

  def overall_tokens_count
    @items.pluck(:tokens_count).sum
  end
end
