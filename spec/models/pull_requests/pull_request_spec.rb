# frozen_string_literal: true
require "rails_helper"

describe PullRequests::PullRequest do
  let(:pull_request_hash) do
    {
      number: 6,
      title: "title",
      html_url: "https://github.com/org/repo/pull/3",
      user: ["some_user", "https://github.com/some_user"],
      updated_at: Time.now.utc,
      changes: changes_hash,
      organization: "org",
      project: "repo",
    }
  end

  let(:changes_hash) do
    {
      file_types: {
        rb: { additions: 6, deletions: 20 },
        js: { additions: 8, deletions: 0 },
        yml: { additions: 10, deletions: 9 },
      },
      additions: 24,
      deletions: 29,
      commits: 6,
    }
  end

  subject do
    described_class.new(pull_request_hash)
  end

  it "has correct title" do
    expect(subject.title).to eq(pull_request_hash[:title])
  end

  it "has correct url" do
    expect(subject.url).to eq(pull_request_hash[:html_url])
  end

  it "has correct project" do
    expect(subject.project).to eq("repo")
  end

  it "has correct organization" do
    expect(subject.organization).to eq("org")
  end

  it "has correct number" do
    expect(subject.number).to eq(6)
  end

  it "has correct additions" do
    expect(subject.additions).to eq(changes_hash[:additions])
  end

  it "has correct deletions" do
    expect(subject.deletions).to eq(changes_hash[:deletions])
  end

  it "has correct commits_count" do
    expect(subject.commits_count).to eq(changes_hash[:commits])
  end

  it "has correct files_types" do
    expect(subject.file_types).to eq(changes_hash[:file_types].keys)
  end

  it "has correct file_changes_per_type" do
    expect(subject.file_changes_per_type).to eq(changes_hash[:file_types])
  end

  describe "#additions_for_file_type" do
    it "returns 0 for a file type that is not present in the hash" do
      expect(subject.additions_for_file_type(:xyz)).to eq(0)
    end

    it "returns additions for a file type that is present in the hash" do
      expect(subject.additions_for_file_type(:js)).to eq(8)
    end
  end
end
