# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  telegram_id    :bigint           not null
#  telegram_data  :jsonb            not null
#  messages_limit :integer          default(5), not null
#
# Indexes
#
#  index_users_on_telegram_id  (telegram_id) UNIQUE
#
class User < ApplicationRecord
  include HasHashid

  has_many :messages, dependent: :destroy

  validates :telegram_id, presence: true, uniqueness: true
  validates :telegram_data, presence: true

  kredis_counter :messages_count, expires_in: 2.hours

  def admin?
    ENV.fetch('TELEGRAM_BOT_ADMIN_IDS').split(',').map(&:to_i).include?(telegram_id)
  end

  def too_many_messages?
    messages_count.value > messages_limit
  end

  def referral_url
    "https://t.me/h3y_gpt_bot?start=#{hashid}"
  end
end
