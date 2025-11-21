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
      expect {
        post sign_up_url, params: { email: "lazaronixon@hey.com", password: "Secret1*3*5*", password_confirmation: "Secret1*3*5*" }
      }.to change(User, :count).by(1)

      expect(response).to redirect_to(root_url)
    end
  end
end

