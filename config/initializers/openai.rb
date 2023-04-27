# frozen_string_literal: true

OpenAI.configure do |config|
  config.access_token = ENV.fetch('OPENAI_ACCESS_TOKEN')
  config.request_timeout = 180
end
