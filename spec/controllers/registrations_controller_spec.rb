require "rails_helper"

RSpec.describe RegistrationsController, type: :request do
  describe "GET /sign_up" do
    it "should get new" do
      get sign_up_url
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /sign_up" do
    it "should sign up" do
      password = SecureRandom.alphanumeric(20) + "!@#"
      email = "newuser@example.com"
      username = "newuser123"

      expect {
        post sign_up_url, params: { email: email, username: username, password: password, password_confirmation: password }
      }.to change(User, :count).by(1)

      expect(response).to redirect_to(root_url)
    end
  end
end
