# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = ENV.fetch('SENTRY_DSN')
  config.enabled_environments = %w[production]
  config.traces_sample_rate = 0.5
end
