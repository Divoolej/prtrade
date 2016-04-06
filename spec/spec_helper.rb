# frozen_string_literal: true
RSpec.configure do |config|
  config.order = "random"

  config.after(:each) do
    Rails.cache.clear
  end
end
