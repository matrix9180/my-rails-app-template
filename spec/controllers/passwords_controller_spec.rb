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
      new_password = SecureRandom.alphanumeric(20) + "!@#"
      patch password_url, params: { password_challenge: user.password, password: new_password, password_confirmation: new_password }
      expect(response).to redirect_to(root_url)
    end

    it "should not update password with wrong password challenge" do
      new_password = SecureRandom.alphanumeric(20) + "!@#"
      patch password_url, params: { password_challenge: "WrongPassword123!@#", password: new_password, password_confirmation: new_password }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to match(/Password challenge is invalid/)
    end
  end
end

