# frozen_string_literal: true

# == Schema Information
#
# Table name: chats
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  telegram_id   :bigint           not null
#  telegram_data :jsonb            not null
#  blocked       :boolean          default(FALSE), not null
#
# Indexes
#
#  index_chats_on_telegram_id  (telegram_id) UNIQUE
#
class Chat < ApplicationRecord
  has_many :messages, dependent: :destroy

  validates :telegram_id, presence: true, uniqueness: true
  validates :telegram_data, presence: true

  def block
    update(blocked: true)
  end

  def unblock
    update(blocked: false)
  end
end
