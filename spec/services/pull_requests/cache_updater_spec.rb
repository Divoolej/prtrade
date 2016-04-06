# frozen_string_literal: true
require "rails_helper"

describe PullRequests::CacheUpdater do
  let(:all_pull_requests_hash) do
    {
      "some_owner" => {
        "project_1" => {
          6 => {
            number: 6,
            title: "Pull Request 6 Title",
            html_url: "https://github.com/some_owner/project_1/pull/6",
            changes: {
              file_types: {
                rb: { additions: 10, deletions: 10 },
              },
              additions: 10,
              deletions: 10,
              commits: 3,
            },
          },
          9 => {
            number: 9,
            title: "Pull Request 9 Title",
            html_url: "https://github.com/some_owner/project_1/pull/9",
            changes: {
              file_types: {
                rb: { additions: 11, deletions: 11 },
              },
              additions: 11,
              deletions: 11,
              commits: 3,
            },
          },
        },
        "project_2" => {
          8 => {
            number: 8,
            title: "Pull Request 8 Title",
            html_url: "https://github.com/some_owner/project_2/pull/8",
            changes: {
              file_types: {
                js: { additions: 1, deletions: 0 },
                rb: { additions: 40, deletions: 10 },
              },
              additions: 41,
              deletions: 10,
              commits: 3,
            },
          },
          29 => {
            number: 29,
            title: "Pull Request 29 Title",
            html_url: "https://github.com/some_owner/project_2/pull/29",
            changes: {
              file_types: {
                rb: { additions: 30, deletions: 11 },
              },
              additions: 30,
              deletions: 11,
              commits: 3,
            },
          },
        },
        "project_3" => {
          12 => {
            number: 12,
            title: "Pull Request 12 Title",
            html_url: "https://github.com/some_owner/project_3/pull/12",
            changes: {
              file_types: {
                rb: { additions: 50, deletions: 10 },
              },
              additions: 50,
              deletions: 10,
              commits: 3,
            },
          },
        },
      },
    }
  end

  let(:pull_request_not_in_cache) do
    {
      number: 77,
      title: "Pull Request 77 Title",
      html_url: "https://github.com/some_owner/project_2/pull/77",
      changes: {
        file_types: {
          cpp: { additions: 77, deletions: 66 },
        },
        additions: 77,
        deletions: 66,
        commits: 33,
      },
    }
  end

  let(:pull_request_in_cache) do
    all_pull_requests_hash["some_owner"]["project_2"][29]
  end

  let(:client) do
    instance_double(Octokit::Client)
  end

  let(:params) do
    {
      action: nil,
      label: { name: "" },
      pull_request: {},
    }
  end

  let(:new_pull_request_formatted) {}
  let(:ready_for_review_label) { ENV["review_label"] }

  describe '#call' do
    subject { described_class.new(params: params, client: client).call }

    before do
      allow_any_instance_of(PullRequests::PullRequestRepository)
        .to receive(:pull_requests).and_return(all_pull_requests_hash)
      allow_any_instance_of(PullRequests::PullRequestRepository)
        .to receive(:new_pull_request_from_json)
        .and_return(pull_request_not_in_cache)
      Rails.cache.write(:pull_requests, all_pull_requests_hash)
    end

    context "when the webhook signals that a pull request has been closed" do
      context "if the pull request was labeled as ready for review" do
        before do
          params.merge!(action: "closed", pull_request: pull_request_in_cache)
        end

        it "removes the pull request from cache" do
          expect { subject }.to change {
            Rails.cache.read(:pull_requests).deep_dup["some_owner"]["project_2"][29]
          }.from(pull_request_in_cache).to(nil)
        end
      end

      context "if the pull request is not labeled as ready for review" do
        before do
          params.merge!(action: "closed", pull_request: pull_request_not_in_cache)
        end

        it "does nothing" do
          expect { subject }.not_to change { Rails.cache.read(:pull_requests).deep_dup }
        end
      end
    end

    context "when the webhook signals that a pull request has been repoened" do
      context "if the pull request was labeled as ready for review" do
        before do
          params.merge!(action: "reopened", pull_request: pull_request_not_in_cache)
          allow(client).to receive(:get).and_return([double(name: ready_for_review_label)])
        end

        it "inserts the pull request into cache" do
          expect { subject }.to change {
            Rails.cache.read(:pull_requests).deep_dup["some_owner"]["project_2"][77]
          }.from(nil).to(pull_request_not_in_cache)
        end
      end

      context "if the pull request is not labeled as ready for review" do
        before do
          params.merge!(action: "reopened", pull_request: pull_request_not_in_cache)
          allow(client).to receive(:get).and_return([double(name: "irrelevant label")])
        end

        it "does nothing" do
          expect { subject }.not_to change { Rails.cache.read(:pull_requests).deep_dup }
        end
      end
    end

    context "when the webhook signals that a pull request has been labeled" do
      context "if the pull request is now labeled as ready for review" do
        before do
          params.merge!(
            action: "labeled",
            pull_request: pull_request_not_in_cache,
            label: { name: ready_for_review_label },
          )
        end

        it "inserts the pull request into cache" do
          expect { subject }.to change {
            Rails.cache.read(:pull_requests).deep_dup["some_owner"]["project_2"][77]
          }.from(nil).to(pull_request_not_in_cache)
        end
      end

      context "if the pull request is still not labeled as ready for review" do
        before do
          params.merge!(
            action: "labeled",
            pull_request: pull_request_not_in_cache,
            label: { name: "irrelevant label" },
          )
        end

        it "does nothing" do
          expect { subject }.not_to change { Rails.cache.read(:pull_requests).deep_dup }
        end
      end
    end

    context "when the webhook signals that a pull request has been unlabeled" do
      context "if the pull request is still labeled as ready for review" do
        before do
          params.merge!(
            action: "unlabeled",
            pull_request: pull_request_not_in_cache,
            label: { name: "irrelevant label" },
          )
        end

        it "does nothing" do
          expect { subject }.not_to change { Rails.cache.read(:pull_requests).deep_dup }
        end
      end

      context "if the pull request is no longer labeled as ready for review" do
        before do
          params.merge!(
            action: "unlabeled",
            pull_request: pull_request_in_cache,
            label: { name: ready_for_review_label },
          )
        end

        it "removes the pull request from cache" do
          expect { subject }.to change {
            Rails.cache.read(:pull_requests).deep_dup["some_owner"]["project_2"][29]
          }.from(pull_request_in_cache).to(nil)
        end
      end
    end

    context "when the webhook signals that a pull request has been synchronized" do
      let(:previous_changes) do
        all_pull_requests_hash["some_owner"]["project_2"][29][:changes]
      end

      let(:current_changes) do
        {
          file_types: {
            rb: { additions: 45, deletions: 15 },
          },
          additions: 45,
          deletions: 15,
          commits: 6,
        }
      end

      let(:updated_pull_request_in_cache) do
        pull_request_in_cache.merge(changes: current_changes)
      end

      before do
        allow_any_instance_of(PullRequests::PullRequestRepository)
          .to receive(:new_pull_request_from_json)
          .and_return(updated_pull_request_in_cache)
      end

      context "if the pull request is labeled as ready for review" do
        before do
          params.merge!(action: "synchronize", pull_request: updated_pull_request_in_cache)
        end

        it "updates the pull request in cache" do
          expect { subject }.to change {
            Rails.cache.read(:pull_requests).deep_dup["some_owner"]["project_2"][29][:changes]
          }.from(previous_changes).to(current_changes)
        end
      end

      context "if the pull request is not labeled as ready for review" do
        before do
          params.merge!(action: "synchronize", pull_request: pull_request_not_in_cache)
        end

        it "does nothing" do
          expect { subject }.not_to change { Rails.cache.read(:pull_requests).deep_dup }
        end
      end
    end
  end
end
