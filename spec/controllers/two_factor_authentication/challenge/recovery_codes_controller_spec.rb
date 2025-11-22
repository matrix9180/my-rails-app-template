require "rails_helper"

RSpec.describe TwoFactorAuthentication::Challenge::RecoveryCodesController, type: :request do
  let(:user) { create(:user, otp_required_for_sign_in: true) }

  describe "GET /two_factor_authentication/challenge/recovery_codes/new" do
    it "should get new" do
      post sign_in_url, params: { email: user.email, password: user.password }
      # Session is set by the sign-in process

      get new_two_factor_authentication_challenge_recovery_codes_url
      expect(response).to have_http_status(:success)
    end

    it "should redirect if challenge token is invalid" do
      get new_two_factor_authentication_challenge_recovery_codes_url
      expect(response).to redirect_to(sign_in_url)
      expect(flash[:alert]).to eq("That's taking too long. Please re-enter your password and try again")
    end
  end

  describe "POST /two_factor_authentication/challenge/recovery_codes" do
    let(:recovery_code) { create(:recovery_code, user: user, used: false) }

    before do
      # Simulate the sign-in process that sets the challenge token
      post sign_in_url, params: { email: user.email, password: user.password }
    end

    it "should sign in with valid recovery code" do
      post two_factor_authentication_challenge_recovery_codes_url, params: { code: recovery_code.code }
      expect(response).to redirect_to(root_url)
      expect(flash[:notice]).to eq("Signed in successfully")
      expect(recovery_code.reload.used).to be true
    end

    it "should not sign in with invalid recovery code" do
      post two_factor_authentication_challenge_recovery_codes_url, params: { code: "invalid_code" }
      expect(response).to redirect_to(new_two_factor_authentication_challenge_recovery_codes_url)
      expect(flash[:alert]).to eq("That code didn't work. Please try again")
    end

    it "should not sign in with used recovery code" do
      recovery_code.update!(used: true)

      post two_factor_authentication_challenge_recovery_codes_url, params: { code: recovery_code.code }
      expect(response).to redirect_to(new_two_factor_authentication_challenge_recovery_codes_url)
      expect(flash[:alert]).to eq("That code didn't work. Please try again")
    end
  end
end
