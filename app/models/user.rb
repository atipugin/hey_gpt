# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  telegram_id   :bigint           not null
#  telegram_data :jsonb            not null
#
# Indexes
#
#  index_users_on_telegram_id  (telegram_id) UNIQUE
#
class User < ApplicationRecord
  MESSAGES_PER_HOUR_LIMIT = 15

  has_many :messages, dependent: :destroy

  validates :telegram_id, presence: true, uniqueness: true
  validates :telegram_data, presence: true

  kredis_counter :messages_count, expires_in: 1.hour

  def admin?
    ENV.fetch('TELEGRAM_BOT_ADMIN_IDS').split(',').map(&:to_i).include?(telegram_id)
  end

  def too_many_messages?
    messages_count.value > MESSAGES_PER_HOUR_LIMIT
  end
end
