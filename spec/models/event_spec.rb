require "rails_helper"

RSpec.describe Event, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "callbacks" do
    describe "before_create" do
      it "sets user_agent from Current" do
        Current.user_agent = "Test Agent"
        user = create(:user)
        event = user.events.build(action: "test_action")
        event.save!
        expect(event.user_agent).to eq("Test Agent")
      end

      it "sets ip_address from Current" do
        Current.ip_address = "127.0.0.1"
        user = create(:user)
        event = user.events.build(action: "test_action")
        event.save!
        expect(event.ip_address).to eq("127.0.0.1")
      end
    end
  end
end

