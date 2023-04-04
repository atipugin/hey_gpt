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
  validates :telegram_id, presence: true, uniqueness: true
  validates :telegram_data, presence: true

  def telegram_user
    @telegram_user ||= Telegram::Bot::Types::User.new(telegram_data)
  end
end
