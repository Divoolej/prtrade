# frozen_string_literal: true
namespace :cache do
  task refresh: :environment do
    Rails.logger.info "Refreshing cache..."
    Mutex.new.synchronize do
      Rails.cache.clear
      @time = Benchmark.ms { PullRequests::PullRequestRepository.new.pull_requests }
    end
    Rails.logger.info "Cache refreshed in #{@time / 1000.0} seconds."
  end
end
