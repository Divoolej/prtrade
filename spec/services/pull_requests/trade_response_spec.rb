# frozen_string_literal: true
require "rails_helper"

describe PullRequests::TradeResponse do
  let(:all_pull_requests) do
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
            title: "Pull Request 8 Title",
            html_url: "https://github.com/owner/project_2/pull/8",
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
            html_url: "https://github.com/owner/project_2/pull/29",
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
            html_url: "https://github.com/owner/project_3/pull/12",
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

  let(:pull_request_repository_class_double) do
    class_double("PullRequests::PullRequestRepository").as_stubbed_const
  end
  let(:pull_request_repository_double) { double(pull_requests: all_pull_requests) }

  let(:trade_request_double) { double }
  let(:suggestions_class_double) { class_double("PullRequests::Suggestions").as_stubbed_const }

  before do
    allow(pull_request_repository_class_double).to receive(:new).and_return(pull_request_repository_double)
  end

  context "when the suggestions are needed" do
    let(:suggestions_object_double) { double(get: suggested_pull_requests) }
    let(:suggested_pull_requests) do
      all_pull_requests["owner"].reject { |k, _v| k == "project_1" }.keys.map do |project_name|
        pull_requests_for_project = []
        all_pull_requests["owner"][project_name].values.each do |pr_attributes|
          pull_requests_for_project << PullRequests::PullRequest.new(pr_attributes.merge(project: project_name))
        end
        pull_requests_for_project
      end.flatten
    end
    let(:formatted_suggestions) do
      "<https://github.com/owner/project_2/pull/8|*project_2 [#8]* - Pull Request 8 Title>" \
        " - _3 commits_ ( 41 :heavy_plus_sign:, 10 :heavy_minus_sign:) `[rb, js]`\n" \
      "<https://github.com/owner/project_2/pull/29|*project_2 [#29]* - Pull Request 29 Title>" \
        " - _3 commits_ ( 30 :heavy_plus_sign:, 11 :heavy_minus_sign:) `[rb]`\n" \
      "<https://github.com/owner/project_3/pull/12|*project_3 [#12]* - Pull Request 12 Title>" \
        " - _3 commits_ ( 50 :heavy_plus_sign:, 10 :heavy_minus_sign:) `[rb]`"
    end

    before do
      allow(trade_request_double).to receive_messages(
        needs_suggestions: true,
        pull_request: all_pull_requests["owner"]["project_1"][6],
        organization: "owner",
        project: "project_1",
      )
      allow(suggestions_class_double).to receive(:new).and_return(suggestions_object_double)
    end

    subject { described_class.new(trade_request: trade_request_double) }

    describe ".new" do
      it "creates a new Suggestions object" do
        expect(suggestions_class_double).to receive(:new).with(trade_request_double)
        subject
      end

      it "gets suggestions from the Suggestions object" do
        expect(suggestions_object_double).to receive(:get)
        subject
      end
    end

    describe "#get" do
      it "returns a Slack payload with a proper username" do
        expect(subject.get[:username]).to eq ENV["bot_name"]
      end

      it "returns a Slack payload with a proper title" do
        expect(subject.get[:text]).to eq I18n.t(
          "pull_requests.suggested_pull_requests",
          traded_pull_request: "<https://github.com/owner/project_1/pull/6|*project_1 [#6]* - Pull Request 6 Title>")
      end

      it "returns a Slack payload with a proper icon" do
        expect(subject.get[:icon_emoji]).to eq ENV["icon_emoji"]
      end

      it "returns a Slack payload with a proper color for attachments" do
        expect(subject.get[:attachments].first[:color]).to eq "#000"
      end

      it "returns a Slack payload supporting markdown in attachments" do
        expect(subject.get[:attachments].first[:mrkdwn_in]).to include(:text)
      end

      it "returns a Slack payload with a list of properly formatted suggested pull requests" do
        expect(subject.get[:attachments].first[:text]).to eq formatted_suggestions
      end
    end
  end

  context "when the suggestions are not needed" do
    subject { described_class.new(trade_request: trade_request_double) }

    let(:formatted_pull_requests) do
      "<https://github.com/owner/project_1/pull/6|* [#6]* - Pull Request 6 Title>" \
        " - _3 commits_ ( 10 :heavy_plus_sign:, 10 :heavy_minus_sign:) `[rb]`\n" \
      "<https://github.com/owner/project_1/pull/9|* [#9]* - Pull Request 9 Title>" \
        " - _3 commits_ ( 11 :heavy_plus_sign:, 11 :heavy_minus_sign:) `[rb]`"
    end

    before do
      allow(trade_request_double).to receive_messages(
        needs_suggestions: false,
        organization: "owner",
        project: "project_1",
      )
    end

    describe ".new" do
      it "does not create any Suggestions objects" do
        expect(suggestions_class_double).not_to receive(:new).with(trade_request_double)
        subject
      end

      context "when the requested project doesn't have any tradable pull requests" do
        before do
          allow(trade_request_double).to receive(:project).and_return("inexistent_project")
        end

        it "should raise NoPullRequestForProjectError exception" do
          expect { subject }.to raise_error(PullRequests::NoPullRequestsForProjectError)
        end
      end
    end

    describe "#get" do
      it "returns a Slack payload with a proper username" do
        expect(subject.get[:username]).to eq ENV["bot_name"]
      end

      it "returns a Slack payload with a proper title" do
        expect(subject.get[:text]).to eq I18n.t("pull_requests.all_pull_requests_for_project",
                                                project_name: trade_request_double.project)
      end

      it "returns a Slack payload with a proper icon" do
        expect(subject.get[:icon_emoji]).to eq ENV["icon_emoji"]
      end

      it "returns a Slack payload with a proper color for attachments" do
        expect(subject.get[:attachments].first[:color]).to eq "#000"
      end

      it "returns a Slack payload supporting markdown in attachments" do
        expect(subject.get[:attachments].first[:mrkdwn_in]).to include(:text)
      end

      it "returns a Slack payload with a list of properly formatted suggested pull requests" do
        expect(subject.get[:attachments].first[:text]).to eq formatted_pull_requests
      end
    end
  end
end
