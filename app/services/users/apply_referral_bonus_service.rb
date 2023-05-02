# frozen_string_literal: true

module Users
  class ApplyReferralBonusService
    include ActsAsService

    def initialize(user:, referrer_id:)
      @user = user
      @referrer_id = referrer_id
    end

    def call
      referrer = User.by_hashid(@referrer_id)
      return failure unless referrer
      return failure if Referral.exists?(referee: @user)
      return failure if referrer == @user
      return failure if @user.created_at >= referrer.created_at
      return failure if @user.created_at < 1.hour.ago

      ActiveRecord::Base.transaction do
        Referral.create!(referrer:, referee: @user)
        referrer.increment(:messages_limit, 5)
        referrer.save!
      end

      success
    end
  end
end
