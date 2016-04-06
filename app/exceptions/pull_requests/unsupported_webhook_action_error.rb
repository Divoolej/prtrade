# frozen_string_literal: true
module PullRequests
  class UnsupportedWebhookActionError < StandardError
    def initialize(action)
      @action = action
    end

    def message
      I18n.t("cache.unsupported_action", action: action)
    end

    private

    attr_reader :action
  end
end
