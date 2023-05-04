# frozen_string_literal: true

module Telegram
  class ProcessBotCommandService
    include ActsAsService
    include HasTelegramBot

    def initialize(message:, chat:, user:)
      @message = message
      @chat = chat
      @user = user
    end

    def call
      case bot_command
      when '/start'
        handle_start_command
      when '/reset'
        handle_reset_command
      when '/stats'
        handle_stats_command
      when '/me'
        handle_me_command
      else
        failure
      end
    end

    private

    def bot_command
      entity = @message.entities.find { |e| e.type == 'bot_command' && e.offset.zero? }
      return unless entity

      @message.text[entity.offset, entity.length]
    end

    def handle_start_command
      @chat.unblock if @chat.blocked?
      if (match = @message.text.match(%r{^/start\s+(\w+)}))
        capture_result_error(Users::ApplyReferralBonusService.new(user: @user, referrer_id: match[1]).call)
      end

      reply_to(chat: @chat, text: t('start.welcome'))

      success
    end

    def handle_reset_command
      @chat.messages.delete_all
      reply_to(chat: @chat, text: t('reset.done'))

      success
    end

    def handle_stats_command
      return failure unless @user.admin?

      users_count = User.count
      active_users_count = Message.select(:user_id).distinct.where(created_at: 1.day.ago..).count
      messages_count = Message.count
      referrals_count = Referral.count
      reply_to(chat: @chat, text: t('stats.text', users_count:, active_users_count:, messages_count:, referrals_count:))

      success
    end

    def handle_me_command
      messages_limit = @user.messages_limit
      messages_left = messages_limit - @user.messages_count.value
      reply_to(
        chat: @chat,
        text: t('me.text', messages_limit:, messages_left:, referral_url: @user.referral_url),
        disable_web_page_preview: true
      )

      success
    end
  end
end
