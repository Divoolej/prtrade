# frozen_string_literal: true
module PullRequests
  class InvalidPullRequestURLError < SlackError
    protected

    def slack_response_attachments
      [
        {
          text: I18n.t("pull_requests.errors.invalid_url"),
          color: "error",
          mrkdwn_in: [:text],
        },
      ]
    end
  end
end
