require "rails_helper"

RSpec.describe Admin::Users::SessionsController, type: :request do
  let(:admin_user) { create(:user, role: :admin) }
  let(:target_user) { create(:user, role: :user, username: "targetuser", email: "target@example.com") }

  describe "GET #index" do
    before do
      sign_in_as admin_user
    end
    it "should get index" do
      get admin_user_sessions_url(target_user.username)
      expect(response).to have_http_status(:success)
    end

    it "should display user's sessions" do
      session1 = create(:session, user: target_user)
      session2 = create(:session, user: target_user)

      get admin_user_sessions_url(target_user.username)
      expect(response.body).to include(session1.user_agent.to_s) if session1.user_agent.present?
      expect(response.body).to include(session1.ip_address.to_s) if session1.ip_address.present?
    end

    it "should order sessions by created_at desc" do
      old_session = create(:session, user: target_user, created_at: 2.days.ago)
      new_session = create(:session, user: target_user, created_at: 1.day.ago)

      get admin_user_sessions_url(target_user.username)
      expect(response).to have_http_status(:success)
    end

    it "should display session details" do
      Current.user_agent = "Test User Agent"
      Current.ip_address = "192.168.1.1"
      session = target_user.sessions.create!

      get admin_user_sessions_url(target_user.username)
      expect(response.body).to include(session.user_agent) if session.user_agent.present?
      expect(response.body).to include(session.ip_address) if session.ip_address.present?
    end

    it "should show message when user has no sessions" do
      get admin_user_sessions_url(target_user.username)
      expect(response.body).to include("no active sessions")
    end

    it "should show sudo badge for active sudo sessions" do
      session = create(:session, user: target_user, sudo_at: 10.minutes.ago)
      get admin_user_sessions_url(target_user.username)
      expect(response.body).to include("Sudo Active")
    end

    it "should find user by username (case insensitive)" do
      get admin_user_sessions_url(target_user.username.upcase)
      expect(response).to have_http_status(:success)
    end
  end

  describe "DELETE #destroy" do
    before do
      sign_in_as admin_user
    end
    it "should delete a session" do
      session = create(:session, user: target_user)
      expect {
        delete admin_user_session_url(target_user.username, session.id)
      }.to change { target_user.sessions.count }.by(-1)
    end

    it "should redirect to sessions index after deletion" do
      session = create(:session, user: target_user)
      delete admin_user_session_url(target_user.username, session.id)
      expect(response).to redirect_to(admin_user_sessions_url(target_user.username))
    end

    it "should show success notice after deletion" do
      session = create(:session, user: target_user)
      delete admin_user_session_url(target_user.username, session.id)
      expect(flash[:notice]).to be_present
    end

    it "should create signed_out event when session is destroyed" do
      session = create(:session, user: target_user)
      expect {
        delete admin_user_session_url(target_user.username, session.id)
      }.to change { target_user.events.where(action: "signed_out").count }.by(1)
    end

    it "should not allow deleting other user's sessions" do
      other_user = create(:user)
      other_session = create(:session, user: other_user)

      # The controller uses @user.sessions.find which will raise RecordNotFound
      # if the session doesn't belong to the user. Rails will catch this and return 404
      delete admin_user_session_url(target_user.username, other_session.id)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE #destroy_all" do
    before do
      sign_in_as admin_user
    end
    it "should delete all user sessions" do
      create(:session, user: target_user)
      create(:session, user: target_user)
      create(:session, user: target_user)

      expect {
        delete destroy_all_admin_user_sessions_url(target_user.username)
      }.to change { target_user.sessions.count }.by(-3)
    end

    it "should redirect to sessions index after deletion" do
      create(:session, user: target_user)
      delete destroy_all_admin_user_sessions_url(target_user.username)
      expect(response).to redirect_to(admin_user_sessions_url(target_user.username))
    end

    it "should show success notice after deletion" do
      create(:session, user: target_user)
      delete destroy_all_admin_user_sessions_url(target_user.username)
      expect(flash[:notice]).to be_present
    end

    it "should create signed_out events for each destroyed session" do
      create(:session, user: target_user)
      create(:session, user: target_user)
      initial_count = target_user.events.where(action: "signed_out").count

      delete destroy_all_admin_user_sessions_url(target_user.username)
      expect(target_user.events.where(action: "signed_out").count).to eq(initial_count + 2)
    end

    it "should handle user with no sessions gracefully" do
      delete destroy_all_admin_user_sessions_url(target_user.username)
      expect(response).to redirect_to(admin_user_sessions_url(target_user.username))
      expect(flash[:notice]).to be_present
    end
  end

  describe "authorization" do
    context "when user is not an admin" do
      let(:regular_user) { create(:user, role: :user) }

      before do
        sign_in_as regular_user
      end

      it "should not allow access to sessions index" do
        get admin_user_sessions_url(target_user.username)
        expect(response).to redirect_to(root_url)
      end

      it "should not allow destroying sessions" do
        session = create(:session, user: target_user)
        delete admin_user_session_url(target_user.username, session.id)
        expect(response).to redirect_to(root_url)
        expect(target_user.sessions.count).to eq(1)
      end

      it "should not allow destroying all sessions" do
        create(:session, user: target_user)
        delete destroy_all_admin_user_sessions_url(target_user.username)
        expect(response).to redirect_to(root_url)
        expect(target_user.sessions.count).to eq(1)
      end
    end

    context "when user is not signed in" do
      it "should redirect to sign in" do
        get admin_user_sessions_url(target_user.username)
        expect(response).to redirect_to(sign_in_url)
      end
    end
  end
end
