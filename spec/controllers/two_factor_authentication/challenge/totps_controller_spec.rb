require "rails_helper"

RSpec.describe TwoFactorAuthentication::Challenge::TotpsController, type: :request do
  let(:user) { create(:user, otp_required_for_sign_in: true) }

  describe "GET /two_factor_authentication/challenge/totp/new" do
    it "should get new" do
      challenge_token = user.signed_id(purpose: :authentication_challenge, expires_in: 20.minutes)
      post sign_in_url, params: { email: user.email, password: user.password }
      # Session is set by the sign-in process

      get new_two_factor_authentication_challenge_totp_url
      expect(response).to have_http_status(:success)
    end

    it "should redirect if challenge token is invalid" do
      get new_two_factor_authentication_challenge_totp_url
      expect(response).to redirect_to(sign_in_url)
      expect(flash[:alert]).to eq("That's taking too long. Please re-enter your password and try again")
    end
  end

  describe "POST /two_factor_authentication/challenge/totp" do
    let(:totp) { ROTP::TOTP.new(user.otp_secret, issuer: "YourAppName") }

    before do
      # Simulate the sign-in process that sets the challenge token
      post sign_in_url, params: { email: user.email, password: user.password }
    end

    it "should sign in with valid TOTP code" do
      code = totp.now

      post two_factor_authentication_challenge_totp_url, params: { code: code }
      expect(response).to redirect_to(root_url)
      expect(flash[:notice]).to eq("Signed in successfully")
    end

    it "should not sign in with invalid TOTP code" do
      post two_factor_authentication_challenge_totp_url, params: { code: "000000" }
      expect(response).to redirect_to(new_two_factor_authentication_challenge_totp_url)
      expect(flash[:alert]).to eq("That code didn't work. Please try again")
    end
  end
end
