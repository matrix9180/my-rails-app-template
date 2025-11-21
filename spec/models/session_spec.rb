require "rails_helper"

RSpec.describe Session, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "callbacks" do
    describe "before_create" do
      it "sets user_agent from Current" do
        Current.user_agent = "Test Agent"
        session = build(:session)
        session.save!
        expect(session.user_agent).to eq("Test Agent")
      end

      it "sets ip_address from Current" do
        Current.ip_address = "127.0.0.1"
        session = build(:session)
        session.save!
        expect(session.ip_address).to eq("127.0.0.1")
      end

      it "sets sudo_at to current time" do
        user = create(:user)
        session = user.sessions.build
        expect(session.sudo_at).to be_nil
        session.save!
        expect(session.sudo_at).to be_within(1.second).of(Time.current)
      end
    end

    describe "after_create" do
      it "creates signed_in event" do
        user = create(:user)
        expect {
          user.sessions.create!
        }.to change { user.events.where(action: "signed_in").count }.by(1)
      end
    end

    describe "after_destroy" do
      it "creates signed_out event" do
        user = create(:user)
        session = user.sessions.create!
        expect {
          session.destroy
        }.to change { user.events.where(action: "signed_out").count }.by(1)
      end
    end
  end

  describe "#sudo?" do
    it "returns true when sudo_at is within 30 minutes" do
      session = create(:session, sudo_at: 15.minutes.ago)
      expect(session.sudo?).to be true
    end

    it "returns false when sudo_at is more than 30 minutes ago" do
      user = create(:user)
      session = user.sessions.create!
      travel 31.minutes
      expect(session.sudo?).to be false
    end
  end
end

