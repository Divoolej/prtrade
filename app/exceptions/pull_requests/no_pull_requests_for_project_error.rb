# frozen_string_literal: true
module PullRequests
  class NoPullRequestsForProjectError < SlackError
    def initialize(organization, project)
      @owner = organization
      @project = project
    end

    protected

    attr_reader :owner, :project

    def slack_response_attachments
      [
        {
          text: I18n.t("pull_requests.errors.no_pull_requests_for_project", owner: owner, project: project),
          color: "danger",
          mrkdwn_in: [:text],
        },
      ]
    end
  end
end
