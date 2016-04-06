# frozen_string_literal: true
require "rails_helper"

describe PullRequests::Suggestions do
  let(:pull_request_repository_data) do
    {
      "owner" => {
        "project_1" => {
          6 => {
            number: 6,
            title: "Pull Request 6 Title",
            html_url: "https://github.com/owner/project_1/pull/6",
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
            html_url: "https://github.com/owner/project_1/pull/9",
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
            title: "Pull Request 12 Title",
            html_url: "https://github.com/owner/project_2/pull/12",
            changes: {
              file_types: {
                rb: { additions: 40, deletions: 10 },
              },
              additions: 40,
              deletions: 10,
              commits: 3,
            },
          },
          29 => {
            number: 29,
            title: "Pull Request 8 Title",
            html_url: "https://github.com/owner/project_2/pull/8",
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
            title: "Pull Request 29 Title",
            html_url: "https://github.com/owner/project_3/pull/29",
            changes: {
              file_types: {
                rb: { additions: 50, deletions: 10 },
              },
              additions: 40,
              deletions: 10,
              commits: 3,
            },
          },
        },
      },
    }
  end

  let(:pull_request_repository_double) { double("PullRequestRepository", pull_requests: pull_request_repository_data) }
  let(:traded_pull_request_hash) { pull_request_repository_data["owner"]["project_1"][6] }
  let(:trade_request_double) do
    double("TradeRequest", pull_request: traded_pull_request_hash, organization: "owner", project: "project_1")
  end

  subject { PullRequests::Suggestions.new(trade_request_double) }

  describe "#get" do
    before(:each) do
      allow(subject).to receive(:pull_request_repository).and_return(pull_request_repository_double)
    end

    it "returns an array of PullRequest objects" do
      result = subject.get
      expect(result.class).to be Array
      expect(result.first.class).to be PullRequests::PullRequest
    end

    it "orders the suggestions and does not suggest pull requests from the traded pull request's project" do
      expect(subject.get.map(&:number)).to eq [29, 8, 12]
    end

    context "when there are no tradable pull requests on github" do
      before do
        allow(pull_request_repository_double).to receive(:pull_requests).and_return({})
      end

      it "returns an empty array" do
        expect(subject.get).to eq []
      end
    end
  end
end
