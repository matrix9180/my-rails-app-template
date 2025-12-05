require "rails_helper"

RSpec.describe SessionsController, type: :request do
  let(:user) { create(:user) }

  describe "GET /sign_in" do
    it "should get new" do
      get sign_in_url
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /sign_in" do
    it "should sign in" do
      post sign_in_url, params: { email: user.email, password: user.password }
      expect(response).to redirect_to(root_url)

      get root_url
      expect(response).to have_http_status(:success)
    end

    it "should redirect to 2FA challenge when user has 2FA enabled" do
      user.update!(otp_required_for_sign_in: true)

      post sign_in_url, params: { email: user.email, password: user.password }
      expect(response).to redirect_to(new_two_factor_authentication_challenge_totp_path)
    end

    it "should not sign in with wrong credentials" do
      post sign_in_url, params: { email: user.email, password: "WrongPassword123!@#" }
      expect(response).to redirect_to(sign_in_url(email_hint: user.email))
      expect(flash[:alert]).to eq("That email or password is incorrect")

      get root_url
      expect(response).to redirect_to(sign_in_url)
    end
  end
end
