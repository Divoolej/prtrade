# frozen_string_literal: true
module PullRequests
  class PullRequestMetric
    # Pull Request similarity is calculated by comparing additions of
    # particular files in pull requests. The lesser score between two requests
    # the more similar they are.
    def self.pr_similarity_score(pull_request_1, pull_request_2)
      final_score = 0.0
      final_score -= score(pull_request_1.additions, pull_request_2.additions)
      all_file_types(pull_request_1, pull_request_2).each do |file_type|
        final_score -= score(
          pull_request_1.additions_for_file_type(file_type),
          pull_request_2.additions_for_file_type(file_type),
        )
      end
      final_score
    end

    def self.all_file_types(pull_request_1, pull_request_2)
      (pull_request_1.file_types | pull_request_2.file_types)
    end

    def self.factor(changes_1, changes_2)
      return 0 if (changes_1 + changes_2) == 0
      (changes_1 - changes_2).abs / (changes_1 + changes_2).to_f
    end

    def self.score(additions_1, additions_2)
      (additions_1 - additions_2).abs * factor(additions_1, additions_2)
    end
  end
end
