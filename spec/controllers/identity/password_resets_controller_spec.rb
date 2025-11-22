require "rails_helper"

RSpec.describe Identity::PasswordResetsController, type: :request do
  let(:user) { create(:user) }

  describe "GET /identity/password_reset/new" do
    it "should get new" do
      get new_identity_password_reset_url
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /identity/password_reset/edit" do
    it "should get edit" do
      sid = user.generate_token_for(:password_reset)

      get edit_identity_password_reset_url(sid: sid)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /identity/password_reset" do
    it "should send a password reset email" do
      expect {
        perform_enqueued_jobs do
          post identity_password_reset_url, params: { email: user.email }
        end
      }.to change { ActionMailer::Base.deliveries.count }.by(1)

      expect(response).to redirect_to(sign_in_url)
      expect(ActionMailer::Base.deliveries.last.subject).to eq("Reset your password")
      expect(ActionMailer::Base.deliveries.last.to).to eq([ user.email ])
    end

    it "should not send a password reset email to a nonexistent email" do
      expect {
        perform_enqueued_jobs do
          post identity_password_reset_url, params: { email: "invalid_email@hey.com" }
        end
      }.not_to change { ActionMailer::Base.deliveries.count }

      expect(response).to redirect_to(new_identity_password_reset_url)
      expect(flash[:alert]).to eq("You can't reset your password until you verify your email")
    end

    it "should not send a password reset email to a unverified email" do
      user.update! verified: false

      expect {
        perform_enqueued_jobs do
          post identity_password_reset_url, params: { email: user.email }
        end
      }.not_to change { ActionMailer::Base.deliveries.count }

      expect(response).to redirect_to(new_identity_password_reset_url)
      expect(flash[:alert]).to eq("You can't reset your password until you verify your email")
    end
  end

  describe "PATCH /identity/password_reset" do
    it "should update password" do
      sid = user.generate_token_for(:password_reset)

      patch identity_password_reset_url, params: { sid: sid, password: "Secret6*4*2*", password_confirmation: "Secret6*4*2*" }
      expect(response).to redirect_to(sign_in_url)
    end

    it "should not update password with expired token" do
      sid = user.generate_token_for(:password_reset)

      travel 30.minutes

      patch identity_password_reset_url, params: { sid: sid, password: "Secret6*4*2*", password_confirmation: "Secret6*4*2*" }

      expect(response).to redirect_to(new_identity_password_reset_url)
      expect(flash[:alert]).to eq("That password reset link is invalid")
    end
  end
end
