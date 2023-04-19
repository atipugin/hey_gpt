# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = ENV.fetch('SENTRY_DSN')
  config.enabled_environments = %w[production]

  # See: https://docs.sentry.io/platforms/ruby/guides/rails/configuration/sampling/
  config.traces_sampler = lambda do |sampling_context|
    next sampling_context[:parent_sampled] unless sampling_context[:parent_sampled].nil?

    transaction_context = sampling_context[:transaction_context]
    op = transaction_context[:op]
    transaction_name = transaction_context[:name]

    case op
    when /http/
      case transaction_name
      when /up/
        0.0
      else
        0.25
      end
    when /sidekiq/
      0.25
    else
      0.0
    end
  end
end
