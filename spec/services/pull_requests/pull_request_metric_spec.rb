# frozen_string_literal: true
require "rails_helper"

describe PullRequests::PullRequestMetric do
  let(:pull_request_1_file_changes) do
    {
      file_types: {
        rb: { additions: 50, deletions: 20 },
        js: { additions: 20, deletions: 4 },
        yaml: { additions: 20, deletions: 12 },
      },
      additions: 90,
      deletions: 36,
      commits: 29,
    }
  end

  let(:pull_request_2_file_changes) do
    {
      file_types: {
        rb: { additions: 30, deletions: 8 },
        js: { additions: 70, deletions: 10 },
        yaml: { additions: 0, deletions: 10 },
        png: { additions: 0, deletions: 0 },
      },
      additions: 100,
      deletions: 28,
      commits: 6,
    }
  end

  let(:pull_request_1) do
    PullRequests::PullRequest.new(attributes_for(:pull_request_attributes, changes: pull_request_1_file_changes))
  end

  let(:pull_request_2) do
    PullRequests::PullRequest.new(attributes_for(:pull_request_attributes, changes: pull_request_2_file_changes))
  end

  describe ".pr_similarity_score" do
    it "calculates correct similarity score" do
      expect(described_class.pr_similarity_score(pull_request_1, pull_request_2).to_i).to eq(-53)
    end
  end

  describe ".all_file_types" do
    it "returns an array of file types from both pull_requests" do
      file_types_array = pull_request_1_file_changes[:file_types].keys | pull_request_2_file_changes[:file_types].keys
      expect(described_class.all_file_types(pull_request_1, pull_request_2)).to eq(file_types_array)
    end
  end

  describe ".factor" do
    it "returns 0 when comparing media file types with 0 additions and deletions" do
      expect(described_class.factor(
               pull_request_1.additions_for_file_type(:png),
               pull_request_2.additions_for_file_type(:png),
      )).to eq(0)
    end

    it "returns the difference between additions divided by the sum of the additions" do
      expect(described_class.factor(
               pull_request_1.additions_for_file_type(:rb),
               pull_request_2.additions_for_file_type(:rb),
      )).to eq(0.25)
    end
  end

  describe ".score" do
    it "returns the difference between additions multiplied by the result of .factor" do
      expect(described_class.score(
               pull_request_1.additions_for_file_type(:rb),
               pull_request_2.additions_for_file_type(:rb),
      )).to eq(5)
    end
  end
end
