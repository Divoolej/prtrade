# frozen_string_literal: true
module PullRequests
  class PullRequestComparison
    attr_reader :suggested_pull_request, :similarity_score

    LOWEST_SCORE = -10_000

    def initialize(traded_pull_request:, suggested_pull_request:)
      @suggested_pull_request = suggested_pull_request
      @similarity_score = if share_file_types(traded_pull_request, suggested_pull_request)
                            PullRequestMetric.pr_similarity_score(traded_pull_request, @suggested_pull_request)
                          else
                            LOWEST_SCORE
                          end
    end

    def <=>(other)
      other.similarity_score <=> similarity_score
    end

    private

    def share_file_types(pull_request_1, pull_request_2)
      (pull_request_1.file_types & pull_request_2.file_types).any?
    end
  end
end
