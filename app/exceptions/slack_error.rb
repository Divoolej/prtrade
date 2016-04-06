# frozen_string_literal: true
class SlackError < StandardError
  def slack_response
    {
      username: ENV["bot_name"],
      response_type: "ephemeral",
      icon_emoji: ENV["error_icon_emoji"],
      attachments: slack_response_attachments,
    }
  end

  protected

  def slack_response_attachments
    [
      {
        text: I18n.t("application_error"),
        color: "warning",
        mrkdwn_in: [:text],
      },
    ]
  end
end
