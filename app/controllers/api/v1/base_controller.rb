# frozen_string_literal: true
module Api
  module V1
    class BaseController < ActionController::Base
      respond_to :json
      before_action :valid_trigger?
      before_action :authenticate!

      expose(:token) { params[:token] }
      expose(:trigger_word) { params[:trigger_word] }

      private

      SUPPORTED_TRIGGER_WORDS = %w(prtrade).freeze

      def authenticate!
        return if token.present? && token == ENV["slack_api_token"]
        render json: { text: I18n.t("shared.no_access") }, status: :unauthorized
      end

      def valid_trigger?
        return if trigger_word.in?(SUPPORTED_TRIGGER_WORDS)
        render json: { text: I18n.t("shared.unprocessable_entity") }, status: :unprocessable_entity
      end
    end
  end
end
