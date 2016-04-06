# frozen_string_literal: true
require "rails_helper"

describe Api::V1::PullRequestsController do
  describe "#status" do
    let(:token) { ENV["slack_api_token"] }
    let(:trade_request) { class_double("PullRequests::TradeRequest").as_stubbed_const }

    it_behaves_like "authorized with valid trigger word"

    context "when the trade requests is correct" do
      let(:trade_request_text) { "prtrade project_name pr_number" }
      let(:trade_response) { class_double("PullRequests::TradeResponse").as_stubbed_const }
      let(:trade_response_object) { double(get: { "response" => "trade_response_get" }) }

      before do
        allow(trade_request).to receive(:new).and_return(nil)
        allow(trade_response).to receive(:new).and_return(trade_response_object)
      end

      it "returns the result of TradeResponse#get" do
        get :status, token: token, text: trade_request_text, trigger_word: "prtrade"
        expect(JSON.parse(response.body)).to eq("response" => "trade_response_get")
      end
    end

    context "when the trade request is empty" do
      let(:empty_trade_request_text) { "prtrade" }

      it "returns an error message from the SlackError exception" do
        expect(trade_request).to receive(:new).and_raise(SlackError)
        get :status, token: token, text: empty_trade_request_text, trigger_word: "prtrade"
        expect(JSON.parse(response.body).keys).to include("username", "attachments")
      end
    end

    context "when the trade request contains too many arguments" do
      let(:invalid_trade_request_text) { "prtrade too many arguments provided" }

      it "returns an error message from the SlackError exception" do
        expect(trade_request).to receive(:new).and_raise(SlackError)
        get :status, token: token, text: invalid_trade_request_text, trigger_word: "prtrade"
        expect(JSON.parse(response.body).keys).to include("username", "attachments")
      end
    end
  end

  describe '#update_cache' do
    before do
      expect(controller).to receive(:sha) { "123" }
    end

    context "with invalid secret" do
      before do
        expect(Rack::Utils).to receive(:secure_compare) { false }
        post :update_cache
      end

      it_behaves_like "unauthorized"
    end

    context "with valid secret" do
      let(:cache_updater) do
        class_double("PullRequests::CacheUpdater")
          .as_stubbed_const
      end
      before do
        allow(request).to receive(:raw_post).and_return('{"action":"labeled"}')
        expect(Rack::Utils).to receive(:secure_compare) { true }
        expect(cache_updater).to receive(:new) { double(call: true) }
        post :update_cache
      end

      it "returns status ok" do
        expect(response).to be_ok
      end
    end
  end
end
