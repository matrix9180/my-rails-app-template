require "rails_helper"

RSpec.describe Identity::EmailsController, type: :request do
  let(:user) { create(:user) }

  before do
    sign_in_as user
  end

  describe "GET /identity/email/edit" do
    it "should get edit" do
      get edit_identity_email_url
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /identity/email" do
    it "should update email" do
      new_email = "new_email@example.com"
      patch identity_email_url, params: { email: new_email, password_challenge: user.password }
      expect(response).to redirect_to(root_url)
    end

    it "should not update email with wrong password challenge" do
      new_email = "new_email@example.com"
      patch identity_email_url, params: { email: new_email, password_challenge: "WrongPassword123!@#" }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to match(/Password challenge is invalid/)
    end
  end
end
