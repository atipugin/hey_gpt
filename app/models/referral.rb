# frozen_string_literal: true

# == Schema Information
#
# Table name: referrals
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  referrer_id :bigint           not null
#  referee_id  :bigint           not null
#
# Indexes
#
#  index_referrals_on_referee_id   (referee_id) UNIQUE
#  index_referrals_on_referrer_id  (referrer_id)
#
class Referral < ApplicationRecord
  belongs_to :referrer, class_name: 'User'
  belongs_to :referee, class_name: 'User'

  validates :referee_id, uniqueness: true
end
