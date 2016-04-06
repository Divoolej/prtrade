# frozen_string_literal: true
require "rails_helper"

describe PullRequests::TradeRequest do
  let(:pull_request_from_repository) do
    { dumy_pull_request_hash: true }
  end

  let(:pull_request_repository) { class_double("PullRequests::PullRequestRepository").as_stubbed_const }
  let(:pull_request_repository_double) { double(pull_request: pull_request_from_repository) }

  before do
    allow(pull_request_repository).to receive(:new).and_return(pull_request_repository_double)
  end

  describe ".new" do
    context "when the trade request text contains only project name" do
      let(:trade_request_text) { "prtrade project_name" }
      subject { described_class.new(request_text: trade_request_text) }

      it "sets @needs_suggestions to false" do
        expect(subject.needs_suggestions).to be false
      end

      it "gets the default organization from the config file" do
        expect(subject.organization).to eq ENV["default_owner"]
      end

      it "sets @project instance variable" do
        expect(subject.project).to eq "project_name"
      end

      it "sets @pull_request to nil" do
        expect(subject.pull_request).to be_nil
      end
    end

    context "when the trade request text contains the pull request URL" do
      let(:trade_request_text_with_url) { "prtrade https://github.com/some_organization/some_project/pull/6" }
      subject { described_class.new(request_text: trade_request_text_with_url) }

      it "sets @needs_suggestions to true" do
        expect(subject.needs_suggestions).to be true
      end

      it "gets the organization from the URL" do
        expect(subject.organization).to eq "some_organization"
      end

      it "gets the project name from the URL" do
        expect(subject.project).to eq "some_project"
      end

      it "gets the pull_request from the PullRequestRepository" do
        expect(subject.pull_request).to eq pull_request_from_repository
      end
    end

    context "when the trade request text contains project name and pull request number" do
      let(:trade_request_text_with_project_and_pr_number) { "prtrade other_project pr_number" }
      subject { described_class.new(request_text: trade_request_text_with_project_and_pr_number) }

      it "sets needs_suggestions to true" do
        expect(subject.needs_suggestions).to be true
      end

      it "gets the default organization from the config file" do
        expect(subject.organization).to eq ENV["default_owner"]
      end

      it "sets the correct project" do
        expect(subject.project).to eq "other_project"
      end

      it "gets the pull_request from the PullRequestRepository" do
        expect(subject.pull_request).to eq pull_request_from_repository
      end
    end

    context "when the trade request is empty" do
      let(:empty_trade_request_text) { "prtrade" }
      subject { described_class.new(request_text: empty_trade_request_text) }

      it "throws an InvalidRequestError" do
        expect { subject }.to raise_error(PullRequests::InvalidRequestError)
      end
    end
  end
end
