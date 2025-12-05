require "rails_helper"

RSpec.describe TwoFactorAuthentication::Profile::TotpsController, type: :request do
  let(:user) { create(:user) }

  before do
    sign_in_as user
  end

  describe "GET /two_factor_authentication/profile/totp/new" do
    it "should get new" do
      get new_two_factor_authentication_profile_totp_url
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /two_factor_authentication/profile/totp" do
    it "should enable 2FA with valid TOTP code" do
      totp = ROTP::TOTP.new(user.otp_secret, issuer: "YourAppName")
      code = totp.now

      expect {
        post two_factor_authentication_profile_totp_url, params: { code: code }
      }.to change { user.reload.otp_required_for_sign_in }.from(false).to(true)

      expect(response).to redirect_to(settings_two_factor_authentication_recovery_codes_path)
    end

    it "should not enable 2FA with invalid TOTP code" do
      post two_factor_authentication_profile_totp_url, params: { code: "000000" }
      expect(response).to redirect_to(new_two_factor_authentication_profile_totp_url)
      expect(flash[:alert]).to eq("That code didn't work. Please try again")
      expect(user.reload.otp_required_for_sign_in).to be false
    end
  end

  describe "PATCH /two_factor_authentication/profile/totp" do
    it "should regenerate OTP secret" do
      old_secret = user.otp_secret

      patch two_factor_authentication_profile_totp_url
      expect(response).to redirect_to(new_two_factor_authentication_profile_totp_url)
      expect(user.reload.otp_secret).not_to eq(old_secret)
    end
  end
end
