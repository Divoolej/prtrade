# frozen_string_literal: true
RSpec.shared_examples "unauthorized" do
  it "returns 401" do
    expect(response).to have_http_status(401)
  end

  it "returns proper json" do
    unauthorized_body = { "text" => I18n.t("shared.no_access") }
    expect(JSON.parse(response.body)).to eq(unauthorized_body)
  end
end

RSpec.shared_examples "authorized with valid trigger word" do
  context "invalid token" do
    before do
      get :status, trigger_word: Api::V1::BaseController::SUPPORTED_TRIGGER_WORDS.sample
    end

    it_behaves_like "unauthorized"
  end

  context "valid token" do
    context "invalid trigger word" do
      it "returns unprocessable_entity" do
        get :status, token: ENV["slack_api_token"]
        expect(response).to have_http_status(422)
      end

      it "returns json" do
        get :status, token: ENV["slack_api_token"]
        unprocessable_entity_body = { "text" => I18n.t("shared.unprocessable_entity") }
        expect(JSON.parse(response.body)).to eq(unprocessable_entity_body)
      end
    end
  end
end
