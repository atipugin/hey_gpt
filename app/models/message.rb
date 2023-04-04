# frozen_string_literal: true

# == Schema Information
#
# Table name: messages
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  chat_id    :bigint           not null
#  text       :text             not null
#
# Indexes
#
#  index_messages_on_chat_id  (chat_id)
#
class Message < ApplicationRecord
  belongs_to :chat

  validates :text, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
