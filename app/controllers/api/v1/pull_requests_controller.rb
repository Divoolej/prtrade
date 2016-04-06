# frozen_string_literal: true
module Api
  module V1
    class PullRequestsController < BaseController
      skip_before_action :authenticate!, only: [:update_cache]
      skip_before_action :valid_trigger?, only: [:update_cache]
      before_action :authenticate_webhook!, only: [:update_cache]

      def status
        request = PullRequests::TradeRequest.new(request_text: params["text"])
        response = PullRequests::TradeResponse.new(trade_request: request)
        render json: response.get
      rescue SlackError => error
        render json: error.slack_response
      end

      def update_cache
        action = JSON.parse(request.raw_post)["action"] # Needed because the "action" field is overriden by Rails
        PullRequests::CacheUpdater.new(params: params.merge(action: action)).call
        render json: { text: I18n.t("cache.success") }, status: :ok
      rescue PullRequests::UnsupportedWebhookActionError => error
        render json: { text: error.message }, status: 422
      end

      private

      def authenticate_webhook!
        verify_signature(sha(request.body.read))
      end

      def verify_signature(sha)
        signature = "sha1=#{sha}"
        unless Rack::Utils.secure_compare(signature, request.env["HTTP_X_HUB_SIGNATURE"])
          render json: { text: I18n.t("shared.no_access") }, status: :unauthorized
        end
      end

      def sha(payload_body)
        OpenSSL::HMAC.hexdigest(
          OpenSSL::Digest::SHA1.new,
          ENV["github_webhook_secret"],
          payload_body,
        )
      end
    end
  end
end
