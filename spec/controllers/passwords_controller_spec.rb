require "rails_helper"

RSpec.describe PasswordsController, type: :request do
  let(:user) { create(:user) }

  before do
    sign_in_as user
  end

  describe "GET /password/edit" do
    it "should get edit" do
      get edit_password_url
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /password" do
    it "should update password" do
      patch password_url, params: { password_challenge: "Secret1*3*5*", password: "Secret6*4*2*", password_confirmation: "Secret6*4*2*" }
      expect(response).to redirect_to(root_url)
    end

    it "should not update password with wrong password challenge" do
      patch password_url, params: { password_challenge: "SecretWrong1*3", password: "Secret6*4*2*", password_confirmation: "Secret6*4*2*" }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to match(/Password challenge is invalid/)
    end
  end
end

