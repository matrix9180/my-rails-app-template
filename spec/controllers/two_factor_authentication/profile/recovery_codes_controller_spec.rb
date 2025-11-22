require "rails_helper"

RSpec.describe TwoFactorAuthentication::Profile::RecoveryCodesController, type: :request do
  let(:user) { create(:user) }

  before do
    sign_in_as user
  end

  describe "GET /two_factor_authentication/profile/recovery_codes" do
    it "should get index and create codes if none exist" do
      expect {
        get two_factor_authentication_profile_recovery_codes_url
      }.to change { user.recovery_codes.count }.from(0).to(10)

      expect(response).to have_http_status(:success)
    end

    it "should get index with existing codes" do
      create_list(:recovery_code, 5, user: user)

      expect {
        get two_factor_authentication_profile_recovery_codes_url
      }.not_to change { user.recovery_codes.count }

      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /two_factor_authentication/profile/recovery_codes" do
    it "should regenerate recovery codes" do
      old_codes = create_list(:recovery_code, 5, user: user)
      old_code_values = old_codes.map(&:code)

      expect {
        post two_factor_authentication_profile_recovery_codes_url
      }.to change { user.recovery_codes.count }.from(5).to(10)

      expect(response).to redirect_to(two_factor_authentication_profile_recovery_codes_url)
      expect(flash[:notice]).to eq("Your new recovery codes have been generated")

      new_code_values = user.recovery_codes.pluck(:code)
      expect(new_code_values).not_to match_array(old_code_values)
    end
  end
end
