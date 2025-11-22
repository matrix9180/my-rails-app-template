require "rails_helper"

RSpec.describe Identity::EmailVerificationsController, type: :request do
  let(:user) { sign_in_as(create(:user)) }

  before do
    user.update! verified: false
  end

  describe "POST /identity/email_verification" do
    it "should send a verification email" do
      expect {
        perform_enqueued_jobs do
          post identity_email_verification_url
        end
      }.to change { ActionMailer::Base.deliveries.count }.by(1)

      expect(response).to redirect_to(root_url)
      expect(ActionMailer::Base.deliveries.last.subject).to eq("Verify your email")
      expect(ActionMailer::Base.deliveries.last.to).to eq([ user.email ])
    end
  end

  describe "GET /identity/email_verification" do
    it "should verify email" do
      sid = user.generate_token_for(:email_verification)

      get identity_email_verification_url(sid: sid, email: user.email)
      expect(response).to redirect_to(root_url)
    end

    it "should not verify email with expired token" do
      sid = user.generate_token_for(:email_verification)

      travel 3.days

      get identity_email_verification_url(sid: sid, email: user.email)

      expect(response).to redirect_to(edit_identity_email_url)
      expect(flash[:alert]).to eq("That email verification link is invalid")
    end
  end
end
