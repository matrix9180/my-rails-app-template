require "rails_helper"

RSpec.describe SessionsController, type: :request do
  let(:user) { create(:user) }

  describe "GET /sessions" do
    it "should get index" do
      sign_in_as user

      get sessions_url
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /sign_in" do
    it "should get new" do
      get sign_in_url
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /sign_in" do
    it "should sign in" do
      post sign_in_url, params: { email: user.email, password: "Secret1*3*5*" }
      expect(response).to redirect_to(root_url)

      get root_url
      expect(response).to have_http_status(:success)
    end

    it "should not sign in with wrong credentials" do
      post sign_in_url, params: { email: user.email, password: "SecretWrong1*3" }
      expect(response).to redirect_to(sign_in_url(email_hint: user.email))
      expect(flash[:alert]).to eq("That email or password is incorrect")

      get root_url
      expect(response).to redirect_to(sign_in_url)
    end
  end

  describe "DELETE /sessions/:id" do
    it "should sign out" do
      sign_in_as user

      delete session_url(user.sessions.last)
      expect(response).to redirect_to(sessions_url)

      follow_redirect!
      expect(response).to redirect_to(sign_in_url)
    end
  end
end

