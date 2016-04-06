# frozen_string_literal: true
module PullRequests
  class PullRequest
    attr_reader :organization, :project, :title, :number, :url

    def initialize(attributes)
      @organization = attributes[:organization]
      @project = attributes[:project]
      @number = attributes[:number]
      @title = attributes[:title]
      @url = attributes[:html_url]
      @changes = attributes[:changes]
    end

    def additions
      @changes[:additions]
    end

    def deletions
      @changes[:deletions]
    end

    def commits_count
      @changes[:commits]
    end

    def file_types
      @changes[:file_types].keys
    end

    def file_changes_per_type
      @changes[:file_types]
    end

    def additions_for_file_type(file_type)
      return 0 unless file_changes_per_type[file_type]
      file_changes_per_type[file_type][:additions]
    end
  end
end
