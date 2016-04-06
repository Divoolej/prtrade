require 'rollbar/rails'
Rollbar.configure do |config|
  config.access_token = ENV['rollbar_token']

  if Rails.env.test?
    config.enabled = false
  end
end
