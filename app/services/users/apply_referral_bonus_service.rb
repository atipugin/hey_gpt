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
      return failure(error: :referrer_not_found) unless referrer
      return failure(error: :already_referred) if Referral.exists?(referee: @user)
      return failure(error: :cant_refer_yourself) if referrer == @user
      return failure(error: :cant_refer_existing_user) if referrer.created_at >= @user.created_at
      return failure(error: :too_late_to_refer) if @user.created_at < 1.hour.ago

      ActiveRecord::Base.transaction do
        Referral.create!(referrer:, referee: @user)
        referrer.increment(:messages_limit, 5)
        referrer.save!
      end

      success
    end
  end
end
