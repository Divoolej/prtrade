# frozen_string_literal: true
module PullRequests
  class Suggestions
    def initialize(trade_request)
      attributes = trade_request.pull_request.merge(
        organization: trade_request.organization,
        project: trade_request.project,
      )
      @number_of_suggestions = ENV["max_suggestions"].to_i || 5
      @pull_request = PullRequest.new(attributes)
      @suggestions = SortedSet.new
    end

    def get
      pull_request_repository.pull_requests.each do |organization, projects|
        projects.each do |project, pull_requests|
          next if project == @pull_request.project && organization == @pull_request.organization
          @suggestions += suggest_pull_requests_for_project(organization, project, pull_requests)
        end
      end
      @suggestions.take(@number_of_suggestions).map(&:suggested_pull_request)
    end

    private

    def suggest_pull_requests_for_project(organization, project, pull_requests_hash)
      new_suggestions = []
      pull_requests_hash.values.each do |single_pull_request_attributes|
        suggested_pull_request = PullRequest.new(single_pull_request_attributes.merge(
                                                   organization: organization,
                                                   project: project))
        new_suggestions << PullRequestComparison.new(
          traded_pull_request: @pull_request,
          suggested_pull_request: suggested_pull_request)
      end
      new_suggestions
    end

    def pull_request_repository
      @pull_request_repository ||= PullRequestRepository.new
    end
  end
end
