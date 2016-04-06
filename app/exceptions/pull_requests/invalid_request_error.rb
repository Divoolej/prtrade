# frozen_string_literal: true
module PullRequests
  class InvalidRequestError < SlackError
    def slack_response
      {
        username: ENV["usage_bot_name"],
        response_type: "ephemeral",
        icon_emoji: ENV["usage_icon_emoji"],
        attachments: slack_response_attachments,
      }
    end

    protected

    def slack_response_attachments
      [
        {
          # This error returns the proper usage in it's Slack response
          text: I18n.t("pull_requests.errors.invalid_request"),
          color: "warning",
          mrkdwn_in: [:text],
        },
      ]
    end
  end
end
