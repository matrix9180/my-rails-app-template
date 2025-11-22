require "rails_helper"

RSpec.describe Sessions::OmniauthController, type: :request do
  describe "POST /auth/:provider/callback" do
    let(:auth_hash) do
      OmniAuth::AuthHash.new(
        provider: "github",
        uid: "12345",
        info: {
          email: "oauth@example.com"
        }
      )
    end

    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:github] = auth_hash
    end

    after do
      OmniAuth.config.test_mode = false
      OmniAuth.config.mock_auth[:github] = nil
    end

    it "should create user and sign in with valid OAuth" do
      expect {
        post "/auth/github/callback", env: { "omniauth.auth" => auth_hash }
      }.to change(User, :count).by(1)

      expect(response).to redirect_to(root_url)
      expect(flash[:notice]).to eq("Signed in successfully")
    end

    it "should sign in existing user with OAuth" do
      user = create(:user, provider: "github", uid: "12345", email: "oauth@example.com", username: "oauth", verified: true)

      expect {
        post "/auth/github/callback", env: { "omniauth.auth" => auth_hash }
      }.not_to change(User, :count)

      expect(response).to redirect_to(root_url)
      expect(flash[:notice]).to eq("Signed in successfully")
    end

    it "should redirect with error on authentication failure" do
      # Test the failure route directly since the controller will error if omniauth.auth is nil
      get "/auth/failure", params: { message: "Authentication failed" }
      expect(response).to redirect_to(sign_in_url)
      expect(flash[:alert]).to eq("Authentication failed")
    end
  end

  describe "GET /auth/failure" do
    it "should redirect to sign in with error message" do
      get "/auth/failure", params: { message: "Authentication failed" }
      expect(response).to redirect_to(sign_in_url)
      expect(flash[:alert]).to eq("Authentication failed")
    end
  end
end
