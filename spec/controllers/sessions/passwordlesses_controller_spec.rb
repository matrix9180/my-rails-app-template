require "rails_helper"

RSpec.describe Sessions::PasswordlessesController, type: :request do
  describe "GET /sessions/passwordless/new" do
    it "should get new" do
      get new_sessions_passwordless_url
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /sessions/passwordless/edit" do
    let(:user) { create(:user, verified: true) }

    it "should sign in with valid token" do
      sign_in_token = user.sign_in_tokens.create!
      sid = sign_in_token.signed_id(expires_in: 1.day)

      get edit_sessions_passwordless_url(sid: sid)
      expect(response).to redirect_to(root_url)
      expect(flash[:notice]).to eq("Signed in successfully")
    end

    it "should not sign in with invalid token" do
      get edit_sessions_passwordless_url(sid: "invalid_token")
      expect(response).to redirect_to(new_sessions_passwordless_url)
      expect(flash[:alert]).to eq("That sign in link is invalid")
    end

    it "should not sign in with expired token" do
      sign_in_token = user.sign_in_tokens.create!
      sid = sign_in_token.signed_id(expires_in: 1.day)
      travel 2.days

      get edit_sessions_passwordless_url(sid: sid)
      expect(response).to redirect_to(new_sessions_passwordless_url)
      expect(flash[:alert]).to eq("That sign in link is invalid")
    end

    it "revokes all sign in tokens after successful sign in" do
      token1 = user.sign_in_tokens.create!
      token2 = user.sign_in_tokens.create!
      sid = token1.signed_id(expires_in: 1.day)

      expect {
        get edit_sessions_passwordless_url(sid: sid)
      }.to change { user.sign_in_tokens.count }.from(2).to(0)
    end
  end

  describe "POST /sessions/passwordless" do
    it "should send passwordless email to verified user" do
      user = create(:user, verified: true)

      expect {
        perform_enqueued_jobs do
          post sessions_passwordless_url, params: { email: user.email }
        end
      }.to change { ActionMailer::Base.deliveries.count }.by(1)

      expect(response).to redirect_to(sign_in_url)
      expect(flash[:notice]).to eq("Check your email for sign in instructions")
      expect(ActionMailer::Base.deliveries.last.subject).to eq("Your sign in link")
      expect(ActionMailer::Base.deliveries.last.to).to eq([ user.email ])
    end

    it "should not send email to unverified user" do
      user = create(:user, verified: false)

      expect {
        perform_enqueued_jobs do
          post sessions_passwordless_url, params: { email: user.email }
        end
      }.not_to change { ActionMailer::Base.deliveries.count }

      expect(response).to redirect_to(new_sessions_passwordless_url)
      expect(flash[:alert]).to eq("You can't sign in until you verify your email")
    end

    it "should not send email to nonexistent user" do
      expect {
        perform_enqueued_jobs do
          post sessions_passwordless_url, params: { email: "nonexistent@example.com" }
        end
      }.not_to change { ActionMailer::Base.deliveries.count }

      expect(response).to redirect_to(new_sessions_passwordless_url)
      expect(flash[:alert]).to eq("You can't sign in until you verify your email")
    end
  end
end
