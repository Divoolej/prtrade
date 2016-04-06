source "https://rubygems.org"
ruby "2.3.0"

gem "rails", "~> 4"

gem "capistrano", "~> 3"
gem "capistrano-bundler"
gem "capistrano-passenger"
gem "capistrano-rails"
gem "responders"
gem "decent_exposure"
gem "httparty"
gem "memcached_store"
gem "newrelic_rpm"
gem "octokit"
gem "rollbar"
gem "rvm1-capistrano3", require: false
gem "whenever"
gem "figaro"

group :development do
  gem "rails_best_practices"
  gem "spring"
  gem "spring-commands-rspec"
end

group :development, :test do
  gem "codeclimate-test-reporter", require: false
  gem "factory_girl_rails"
  gem "faker"
  gem "guard-rspec"
  gem "guard-rubocop"

  gem "pry-rails"
  gem "pry-byebug"
  gem "rspec-rails"
  gem "simplecov"
end

group :staging, :production do
  gem 'lograge'
end
