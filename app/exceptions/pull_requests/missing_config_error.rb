# frozen_string_literal: true
module PullRequests
  class MissingConfigError < SlackError
    protected

    def slack_response_attachments
      [
        {
          text: I18n.t("pull_requests.errors.missing_config", config_entry: message),
          color: "error",
          mrkdwn_in: [:text],
        },
      ]
    end
  end
end
