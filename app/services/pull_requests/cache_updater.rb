# frozen_string_literal: true
module PullRequests
  class CacheUpdater
    def initialize(params:, client: nil)
      @action = params[:action]
      @webhook_action_label = Label.new(params[:label][:name]) if params[:label]
      @pull_request = params[:pull_request]
      @organization, @project = parse_pull_request_url
      @client = client || Octokit::Client.new(
        access_token: ENV["github_api_token"],
        auto_paginate: true,
      )
    end

    def call
      method_name = "react_to_pull_request_#{@action}".to_sym
      raise UnsupportedWebhookActionError.new(@action) unless private_methods.include?(method_name)
      Mutex.new.synchronize do
        old_pull_requests = Rails.cache.read(:pull_requests) || {}
        return unless (updated_pull_requests = send(method_name, old_pull_requests))
        Rails.cache.write(:pull_requests, updated_pull_requests)
      end
    end

    private

    attr_reader :organization, :project, :client, :pull_request, :webhook_action_label

    def react_to_pull_request_reopened(pull_requests)
      return unless labels.include?(review_label)
      add_pull_request(pull_requests_hash: pull_requests, added_pull_request: new_pull_request)
    end

    def react_to_pull_request_closed(pull_requests)
      return unless exists_in_cache?
      remove_pull_request(pull_requests_hash: pull_requests, removed_pull_request: pull_request)
    end

    def react_to_pull_request_labeled(pull_requests)
      return unless webhook_action_label == review_label
      add_pull_request(pull_requests_hash: pull_requests, added_pull_request: new_pull_request)
    end

    def react_to_pull_request_unlabeled(pull_requests)
      if exists_in_cache? && webhook_action_label == review_label
        remove_pull_request(pull_requests_hash: pull_requests, removed_pull_request: pull_request)
      end
    end

    def react_to_pull_request_synchronize(pull_requests)
      return unless exists_in_cache?
      add_pull_request(pull_requests_hash: pull_requests, added_pull_request: new_pull_request)
    end

    def new_pull_request
      @new_pull_request ||= pull_request_repository.new_pull_request_from_json(pull_request)
    end

    def add_pull_request(pull_requests_hash:, added_pull_request:)
      pull_requests_hash.deep_merge(
        organization => { project => { added_pull_request[:number] => added_pull_request } },
      )
    end

    def remove_pull_request(pull_requests_hash:, removed_pull_request:)
      pull_requests_hash[organization][project].delete(removed_pull_request[:number])
      pull_requests_hash
    end

    def labels
      client.get("#{pull_request[:issue_url]}/labels").map do |label|
        Label.new(label.name)
      end
    end

    def exists_in_cache?
      pull_request_repository.pull_requests.fetch(organization).fetch(project).fetch(pull_request[:number])
    rescue KeyError
      return false
    end

    def parse_pull_request_url
      @pull_request[:html_url].split("/")[-4..-3]
    end

    def review_label
      @review_label ||= Label.new(ENV["review_label"])
    end

    def pull_request_repository
      @pull_request_repository ||= PullRequestRepository.new(github_api_client: client)
    end
  end
end
