# frozen_string_literal: true
require "rails_helper"

describe PullRequests::PullRequestComparison do
  let(:traded_pull_request) { PullRequests::PullRequest.new(build(:pull_request_attributes)) }
  let(:suggested_pull_request) do
    attributes = build(:pull_request_attributes, :different_changes_with_shared_file_types)
    PullRequests::PullRequest.new(attributes)
  end

  describe ".new" do
    subject do
      described_class.new(traded_pull_request: traded_pull_request,
                          suggested_pull_request: suggested_pull_request)
    end

    context "when compared pull requests share some file types" do
      it "sets the similarity score using PullRequestMetric" do
        expected_score = PullRequests::PullRequestMetric.pr_similarity_score(traded_pull_request,
                                                                             suggested_pull_request)
        expect(subject.similarity_score).to eq expected_score
      end

      it "stores the suggested_pull_request" do
        expect(subject.suggested_pull_request).to eq suggested_pull_request
      end
    end

    context "when compared pull requests doesn't share any file types" do
      let(:suggested_pull_request) do
        attributes = build(:pull_request_attributes, :different_changes_without_shared_file_types)
        PullRequests::PullRequest.new(attributes)
      end

      it "sets the similarity score to -10_000" do
        expect(subject.similarity_score).to eq(-10_000)
      end

      it "stores the suggested_pull_request" do
        expect(subject.suggested_pull_request).to eq suggested_pull_request
      end
    end
  end

  describe "<=>" do
    let(:other_pull_request_comparison) { double(similarity_score: 100) }

    subject do
      described_class.new(traded_pull_request: traded_pull_request,
                          suggested_pull_request: suggested_pull_request)
    end

    it "compares two PullRequestComparison objects based on their similarity score" do
      expectation = other_pull_request_comparison.similarity_score <=> subject.similarity_score
      expect(subject <=> other_pull_request_comparison).to eq expectation
    end
  end
end
