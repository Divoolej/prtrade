# frozen_string_literal: true
require "rails_helper"

describe PullRequests::PullRequestRepository do
  let(:some_owner) { ENV["default_owner"] }

  let(:all_pull_requests_api_response) do
    [
      {
        base: { repo: { name: "project_1" } },
        user: { login: "octocat", html_url: "https://github.com/octocat" },
        number: 6,
        title: "Pull Request 6 Title",
        url: "https://api.github.com/repos/#{some_owner}/project_1/pulls/6",
        html_url: "https://github.com/#{some_owner}/project_1/pull/6",
        updated_at: "2011-01-26T19:01:12Z",
        additions: 10,
        deletions: 10,
        commits: 3,
        files_api_response: [
          {
            filename: "some_file.rb",
            additions: 10,
            deletions: 10,
          },
        ],
      },
      {
        base: { repo: { name: "project_1" } },
        user: { login: "octocat", html_url: "https://github.com/octocat" },
        number: 9,
        title: "Pull Request 9 Title",
        url: "https://api.github.com/repos/#{some_owner}/project_1/pulls/9",
        html_url: "https://github.com/#{some_owner}/project_1/pull/9",
        updated_at: "2011-01-26T19:01:12Z",
        additions: 11,
        deletions: 11,
        commits: 3,
        files_api_response: [
          {
            filename: "some_file.rb",
            additions: 11,
            deletions: 11,
          },
        ],
      },
      {
        base: { repo: { name: "project_2" } },
        user: { login: "octocat", html_url: "https://github.com/octocat" },
        number: 8,
        title: "Pull Request 8 Title",
        url: "https://api.github.com/repos/#{some_owner}/project_2/pulls/8",
        html_url: "https://github.com/#{some_owner}/project_2/pull/8",
        updated_at: "2011-01-26T19:01:12Z",
        additions: 41,
        deletions: 10,
        commits: 3,
        files_api_response: [
          {
            filename: "some_file.rb",
            additions: 40,
            deletions: 10,
          },
          {
            filename: "some_file.js",
            additions: 1,
            deletions: 0,
          },
        ],
      },
      {
        base: { repo: { name: "project_2" } },
        user: { login: "octocat", html_url: "https://github.com/octocat" },
        number: 29,
        title: "Pull Request 29 Title",
        url: "https://api.github.com/repos/#{some_owner}/project_2/pulls/29",
        html_url: "https://github.com/#{some_owner}/project_2/pull/29",
        updated_at: "2011-01-26T19:01:12Z",
        additions: 30,
        deletions: 11,
        commits: 3,
        files_api_response: [
          {
            filename: "some_file.rb",
            additions: 30,
            deletions: 11,
          },
        ],
      },
      {
        base: { repo: { name: "project_3" } },
        user: { login: "octocat", html_url: "https://github.com/octocat" },
        number: 12,
        title: "Pull Request 12 Title",
        url: "https://api.github.com/repos/#{some_owner}/project_3/pulls/12",
        html_url: "https://github.com/#{some_owner}/project_3/pull/12",
        updated_at: "2011-01-26T19:01:12Z",
        additions: 50,
        deletions: 10,
        commits: 3,
        files_api_response: [
          {
            filename: "some_file.rb",
            additions: 50,
            deletions: 10,
          },
        ],
      },
    ]
  end

  let(:expected_all_pull_requests_hash) do
    {
      some_owner => {
        "project_1" => {
          6 => {
            number: 6,
            title: "Pull Request 6 Title",
            html_url: "https://github.com/#{some_owner}/project_1/pull/6",
            user: ["octocat", "https://github.com/octocat"],
            updated_at: "2011-01-26T19:01:12Z",
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
            html_url: "https://github.com/#{some_owner}/project_1/pull/9",
            user: ["octocat", "https://github.com/octocat"],
            updated_at: "2011-01-26T19:01:12Z",
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
            html_url: "https://github.com/#{some_owner}/project_2/pull/8",
            user: ["octocat", "https://github.com/octocat"],
            updated_at: "2011-01-26T19:01:12Z",
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
            html_url: "https://github.com/#{some_owner}/project_2/pull/29",
            user: ["octocat", "https://github.com/octocat"],
            updated_at: "2011-01-26T19:01:12Z",
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
            html_url: "https://github.com/#{some_owner}/project_3/pull/12",
            user: ["octocat", "https://github.com/octocat"],
            updated_at: "2011-01-26T19:01:12Z",
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

  before do
    allow_any_instance_of(Octokit::Client).to receive_message_chain(:get, :select, :map)
      .and_return(all_pull_requests_api_response)

    all_pull_requests_api_response.each do |pull_request|
      allow_any_instance_of(Octokit::Client).to receive(:get).with("#{pull_request[:url]}/files")
        .and_return(pull_request[:files_api_response])
    end
  end

  describe ".new" do
    subject { described_class.new }

    context "when the review label is not set" do
      before do
        allow(ENV).to receive(:[]).with("review_label").and_return(nil)
      end

      it "throws MissingConfigError when the review label is not set" do
        expect { subject }.to raise_error(PullRequests::MissingConfigError)
      end
    end

    context "with no parameters given" do
      it "creates a new instance of Octokit::Client" do
        expect(Octokit::Client).to receive(:new)
        subject
      end
    end

    context "with a github api client reference as a parameter" do
      subject { described_class.new(github_api_client: :github_client_placeholder) }

      it "does not create a new instance of Octocit::Client" do
        expect(Octokit::Client).not_to receive(:new)
        subject
      end
    end
  end

  describe "#pull_request" do
    subject { described_class.new.pull_request(some_owner, "project_1", 6) }

    context "when the requested pull request exists in cache" do
      before do
        Rails.cache.write(:pull_requests, expected_all_pull_requests_hash)
      end

      it "returns a hash for a given pull request" do
        expect(subject).to eq expected_all_pull_requests_hash[some_owner]["project_1"][6]
      end
    end

    context "when the requested pull request doesn't exist in cache" do
      before do
        Rails.cache.write(:pull_requests, some_owner => {})
      end

      it "throws a MissingPullRequestError exception" do
        expect { subject }.to raise_error(PullRequests::MissingPullRequestError)
      end
    end
  end

  describe "#pull_requests" do
    subject { described_class.new.pull_requests }

    context "when the cache is empty" do
      context "if the default owner is set" do
        it "fetches all pull requests for a given owner that are ready for review" do
          expected_options = hash_including(labels: ENV["review_label"])
          expected_issues_url = "/orgs/#{some_owner}/issues"
          expect_any_instance_of(Octokit::Client).to receive(:get).with(expected_issues_url, expected_options)
          subject
        end

        it "returns a hash of all pull requests for given organization's projects" do
          expect(subject).to eq expected_all_pull_requests_hash
        end
      end

      context "if the default owner is not set" do
        before do
          @default_owner = ENV["default_owner"]
          ENV["default_owner"] = nil
        end

        after do
          ENV["default_owner"] = @default_owner
        end

        it "throws a MissingConfigError exception" do
          expect { subject }.to raise_error(PullRequests::MissingConfigError)
        end
      end
    end

    context "when the cache is not empty" do
      before do
        Rails.cache.write(:pull_requests, expected_all_pull_requests_hash)
      end

      it "does not fetch pull requests from Github API" do
        expect(an_instance_of(Octokit::Client)).not_to receive(:get)
        subject
      end

      it "returns a hash of all pull requests for given organization's projects" do
        expect(subject).to eq expected_all_pull_requests_hash
      end
    end
  end
end
