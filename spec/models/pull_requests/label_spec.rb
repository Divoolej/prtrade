# frozen_string_literal: true
require "rails_helper"

describe PullRequests::Label do
  subject { PullRequests::Label.new("Some Label") }

  describe "to_s" do
    it "returns the label name in lowercase" do
      expect(subject.to_s).to eq "some label"
    end
  end

  describe "#==" do
    let(:identical_label) { PullRequests::Label.new("some label") }
    let(:different_label) { PullRequests::Label.new("some other label") }

    it "compares the labels using their #to_s methods" do
      aggregate_failures do
        expect(subject).to eq identical_label
        expect(subject).not_to eq different_label
      end
    end
  end
end
