# frozen_string_literal: true

# == Schema Information
#
# Table name: messages
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  telegram_id   :bigint           not null
#  telegram_data :jsonb            not null
#  chat_id       :bigint           not null
#  user_id       :bigint
#  tokens_count  :integer          default(0), not null
#
# Indexes
#
#  index_messages_on_chat_id      (chat_id)
#  index_messages_on_telegram_id  (telegram_id) UNIQUE
#  index_messages_on_user_id      (user_id)
#
class Message < ApplicationRecord
  belongs_to :chat
  belongs_to :user, optional: true

  validates :telegram_id, presence: true, uniqueness: true
  validates :telegram_data, presence: true

  delegate :text, :entities, to: :telegram_message

  before_save :count_tokens, if: -> { text.present? }

  scope :before_message, ->(m) { where('telegram_id < ?', m.telegram_id).order(telegram_id: :desc) }
  scope :with_text, -> { where.not(tokens_count: 0) }

  def telegram_message
    @telegram_message ||= Telegram::Bot::Types::Message.new(telegram_data)
  end

  def bot_command?
    bot_command.present?
  end

  def bot_command
    @bot_command ||= begin
      entity = Array(entities).find { |e| e.type == 'bot_command' && e.offset.zero? }

      text[entity.offset, entity.length] if entity
    end
  end

  private

  def count_tokens
    self[:tokens_count] = Tokenizer.instance.gpt2.encode(text).tokens.count
  end
end
