# frozen_string_literal: true
module PullRequests
  class TradeResponse
    include ActionView::Helpers::TextHelper

    def initialize(trade_request:)
      organization_and_project = { organization: trade_request.organization, project: trade_request.project }
      if trade_request.needs_suggestions
        suggestions = Suggestions.new(trade_request).get
        @pull_request = PullRequest.new(trade_request.pull_request.merge(organization_and_project))
        @response = list_pull_requests_from_suggestions(suggestions)
      else
        @response = list_all_pull_requests_for_project(organization_and_project)
      end
    end

    def get
      slack_response
    end

    private

    def list_pull_requests_from_suggestions(suggested_pull_requests)
      listed_pull_requests = formatted_pull_requests(suggested_pull_requests)
      {
        title: I18n.t("pull_requests.suggested_pull_requests",
                      traded_pull_request: string_for_pull_request_title(@pull_request)),
        pull_requests: listed_pull_requests.join("\n"),
      }
    end

    def list_all_pull_requests_for_project(organization:, project:)
      listed_pull_requests = formatted_pull_requests(pull_request_objects(organization, project))
      {
        title: I18n.t("pull_requests.all_pull_requests_for_project", project_name: project),
        pull_requests: listed_pull_requests.join("\n"),
      }
    end

    def pull_request_objects(organization, project)
      pull_request_repository.pull_requests[organization][project].values.map do |pr_attributes|
        PullRequest.new(pr_attributes)
      end
    rescue
      raise NoPullRequestsForProjectError.new(organization, project)
    end

    def formatted_pull_requests(pull_requests)
      pull_requests.map do |pull_request_object|
        formatted_pull_request(pull_request_object)
      end
    end

    def formatted_pull_request(pull_request_object)
      pull_request_title = string_for_pull_request_title(pull_request_object)
      pull_request_changes = string_for_pull_request_changes(pull_request_object)
      pull_request_title + pull_request_changes
    end

    def string_for_pull_request_title(pull_request)
      pull_request_title = truncate(pull_request.title, length: 35)
      "<#{pull_request.url}|*#{pull_request.project} [##{pull_request.number}]* - #{pull_request_title}>"
    end

    def string_for_pull_request_changes(pull_request)
      commits = pluralize(pull_request.commits_count, "commit")
      files = sort_file_types(pull_request.file_changes_per_type).first(5).join(", ")
      additions = pull_request.additions
      deletions = pull_request.deletions
      " - _#{commits}_ ( #{additions} :heavy_plus_sign:, #{deletions} :heavy_minus_sign:) `[#{files}]`"
    end

    def sort_file_types(file_types_hash)
      file_types_hash.keys.sort do |type1, type2|
        file_types_hash[type2][:additions] <=> file_types_hash[type1][:additions]
      end
    end

    def slack_response
      {
        username: ENV["bot_name"],
        text: @response[:title],
        icon_emoji: ENV["icon_emoji"],
        attachments: slack_attachments,
      }
    end

    def slack_attachments
      [
        {
          text: @response[:pull_requests],
          color: "#000",
          mrkdwn_in: [:text],
        },
      ]
    end

    def pull_request_repository
      @pull_request_repository ||= PullRequestRepository.new
    end
  end
end
