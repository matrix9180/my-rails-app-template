require "rails_helper"

RSpec.describe Sessions::SudosController, type: :request do
  let(:user) { create(:user) }

  before do
    sign_in_as user
  end

  describe "GET /sessions/sudo/new" do
    it "should get new" do
      get new_sessions_sudo_url
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /sessions/sudo" do
    it "should authenticate with correct password" do
      proceed_to_url = root_url
      post sessions_sudo_url, params: { password: user.password, proceed_to_url: proceed_to_url }
      expect(response).to redirect_to(proceed_to_url)
    end

    it "should not authenticate with incorrect password" do
      proceed_to_url = root_url
      post sessions_sudo_url, params: { password: "WrongPassword123!@#", proceed_to_url: proceed_to_url }
      expect(response).to redirect_to(new_sessions_sudo_path(proceed_to_url: proceed_to_url))
      expect(flash[:alert]).to eq("The password you entered is incorrect")
    end

    it "updates sudo_at timestamp" do
      session = user.sessions.last
      old_sudo_at = session.sudo_at
      travel 1.hour

      post sessions_sudo_url, params: { password: user.password, proceed_to_url: root_url }
      session.reload
      expect(session.sudo_at).to be > old_sudo_at
    end
  end
end
