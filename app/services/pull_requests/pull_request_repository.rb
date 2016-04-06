# frozen_string_literal: true
module PullRequests
  class PullRequestRepository
    def initialize(github_api_client: nil)
      @review_label = ENV["review_label"] || raise(MissingConfigError, "review_label")
      @github_api_client = github_api_client || Octokit::Client.new(
        access_token: ENV["github_api_token"],
        auto_paginate: true,
      )
    end

    def pull_request(owner, project_name, pull_request_number)
      pull_requests
        .try(:[], owner)
        .try(:[], project_name)
        .try(:[], pull_request_number) || raise(MissingPullRequestError.new(owner, project_name, pull_request_number))
    end

    def pull_requests
      Rails.cache.fetch(:pull_requests) do
        owner = ENV["default_owner"] || raise(MissingConfigError, "owner")
        { owner => get_repos_and_pull_requests_for_owner(owner) }
      end
    end

    def new_pull_request_from_json(pull_request_json)
      single_pull_request_hash(pull_request_json)
    end

    private

    attr_reader :github_api_client, :review_label

    def get_repos_and_pull_requests_for_owner(owner)
      repos_and_pull_requests_hash = Hash.new { |hash, repo| hash[repo] = {} }
      tradable_pull_requests_for_owner(owner).each do |pull_request|
        repo = pull_request[:base][:repo][:name]
        repos_and_pull_requests_hash[repo].reverse_merge!(
          pull_request[:number] => single_pull_request_hash(pull_request),
        )
      end
      repos_and_pull_requests_hash.default_proc = nil # Hashes with a default_proc cannot be cached
      repos_and_pull_requests_hash
    end

    def tradable_pull_requests_for_owner(owner)
      # We need to fetch /issues, because github doesn't
      # provide info about labels in their /pull_requests endpoint
      # and technichally every pull_request is an issue
      request_params = { filter: :all, labels: review_label, sort: :updated }
      issues_path = "/orgs/#{owner}/issues"
      github_api_client.get(issues_path, request_params).select(&:pull_request?).map do |issue|
        github_api_client.get(issue.pull_request.url)
      end
    end

    def single_pull_request_hash(pull_request)
      {
        number: pull_request[:number],
        title: pull_request[:title],
        html_url: pull_request[:html_url],
        user: [pull_request[:user][:login], pull_request[:user][:html_url]],
        updated_at: pull_request[:updated_at],
        changes: pull_request_changes_hash(pull_request),
      }
    end

    def pull_request_changes_hash(pull_request)
      files = github_api_client.get("#{pull_request[:url]}/files")
      {
        file_types: file_types_hash(files),
        additions: pull_request[:additions],
        deletions: pull_request[:deletions],
        commits: pull_request[:commits],
      }
    end

    def file_types_hash(files)
      file_types = Hash.new { |hash, file_type| hash[file_type] = { additions: 0, deletions: 0 } }
      files.each do |file|
        file_type = file[:filename].split("/").last.split(".").last
        update_file_type_hash(file_types[file_type.to_sym], file)
      end
      file_types.default_proc = nil # Hashes with a default_proc cannot be cached
      file_types
    end

    def update_file_type_hash(file_type_hash, new_file)
      file_type_hash[:additions] += new_file[:additions]
      file_type_hash[:deletions] += new_file[:deletions]
    end
  end
end
