# frozen_string_literal: true
module PullRequests
  class MissingPullRequestError < SlackError
    def initialize(owner, project, pull_request_number)
      @owner = owner
      @project = project
      @pull_request_number = pull_request_number
    end

    protected

    attr_reader :owner, :project, :pull_request_number

    def slack_response_attachments
      [
        {
          text: I18n.t("pull_requests.errors.missing_pull_request",
                       owner: owner,
                       project: project,
                       pull_request_number: pull_request_number),
          color: "warning",
          mrkdwn_in: [:text],
        },
      ]
    end
  end
end
