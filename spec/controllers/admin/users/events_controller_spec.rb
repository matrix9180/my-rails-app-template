require "rails_helper"

RSpec.describe Admin::Users::EventsController, type: :request do
  let(:admin_user) { create(:user, role: :admin) }
  let(:target_user) { create(:user, role: :user, username: "targetuser", email: "target@example.com") }

  describe "GET #index" do
    before do
      sign_in_as admin_user
    end
    it "should get index" do
      get admin_user_events_url(target_user.username)
      expect(response).to have_http_status(:success)
    end

    it "should display user's events" do
      event1 = target_user.events.create!(action: "signed_in")
      event2 = target_user.events.create!(action: "signed_out")

      get admin_user_events_url(target_user.username)
      expect(response.body).to include(event1.action)
      expect(response.body).to include(event2.action)
    end

    it "should order events by created_at desc" do
      old_event = target_user.events.create!(action: "signed_in", created_at: 2.days.ago)
      new_event = target_user.events.create!(action: "signed_out", created_at: 1.day.ago)

      get admin_user_events_url(target_user.username)
      expect(response).to have_http_status(:success)
      # Check that newer event appears first in the response
      expect(response.body.index(new_event.action)).to be < response.body.index(old_event.action)
    end

    it "should paginate events" do
      30.times { target_user.events.create!(action: "test_action") }
      get admin_user_events_url(target_user.username)
      expect(response).to have_http_status(:success)
    end

    it "should display event details" do
      Current.user_agent = "Test User Agent"
      Current.ip_address = "192.168.1.1"
      event = target_user.events.create!(action: "signed_in")

      get admin_user_events_url(target_user.username)
      expect(response.body).to include(event.action)
      expect(response.body).to include(event.user_agent) if event.user_agent.present?
      expect(response.body).to include(event.ip_address) if event.ip_address.present?
    end

    it "should show message when user has no events" do
      get admin_user_events_url(target_user.username)
      expect(response.body).to include("no events")
    end

    it "should find user by username (case insensitive)" do
      get admin_user_events_url(target_user.username.upcase)
      expect(response).to have_http_status(:success)
    end
  end

  describe "authorization" do
    context "when user is not an admin" do
      let(:regular_user) { create(:user, role: :user) }

      before do
        sign_in_as regular_user
      end

      it "should not allow access to events index" do
        get admin_user_events_url(target_user.username)
        expect(response).to redirect_to(root_url)
      end
    end

    context "when user is not signed in" do
      it "should redirect to sign in" do
        get admin_user_events_url(target_user.username)
        expect(response).to redirect_to(sign_in_url)
      end
    end
  end
end
