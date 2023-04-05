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

  delegate :text, to: :telegram_message

  def telegram_message
    @telegram_message ||= Telegram::Bot::Types::Message.new(telegram_data)
  end
end
