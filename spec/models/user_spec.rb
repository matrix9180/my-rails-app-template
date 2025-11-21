require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { should have_many(:sessions).dependent(:destroy) }
    it { should have_many(:recovery_codes).dependent(:destroy) }
    it { should have_many(:sign_in_tokens).dependent(:destroy) }
    it { should have_many(:events).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:user) }

    it { should validate_presence_of(:email) }
    it { should allow_value("user@example.com").for(:email) }
    it { should_not allow_value("invalid").for(:email) }
    it { should_not allow_value("invalid@").for(:email) }
    it { should validate_length_of(:password).is_at_least(12) }

    it "validates email uniqueness case insensitively" do
      create(:user, email: "test@example.com")
      user = build(:user, email: "TEST@EXAMPLE.COM")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end
  end

  describe "email normalization" do
    it "normalizes email to lowercase" do
      user = create(:user, email: "Test@Example.COM")
      expect(user.email).to eq("test@example.com")
    end

    it "strips whitespace from email" do
      user = create(:user, email: "  test@example.com  ")
      expect(user.email).to eq("test@example.com")
    end
  end

  describe "callbacks" do
    describe "before_validation on create" do
      it "generates otp_secret" do
        user = build(:user)
        expect(user.otp_secret).to be_nil
        user.valid?
        expect(user.otp_secret).to be_present
      end
    end

    describe "before_validation on update" do
      it "sets verified to false when email changes" do
        user = create(:user, verified: true)
        user.update!(email: "newemail@example.com")
        expect(user.verified).to be false
      end

      it "does not change verified when email does not change" do
        user = create(:user, verified: true)
        user.update!(verified: true)
        expect(user.verified).to be true
      end
    end

    describe "after_update" do
      it "creates password_changed event when password changes" do
        user = create(:user)
        expect {
          user.update!(password: SecureRandom.alphanumeric(20) + "!@#")
        }.to change { user.events.where(action: "password_changed").count }.by(1)
      end

      it "creates email_verification_requested event when email changes" do
        user = create(:user)
        expect {
          user.update!(email: "newemail@example.com")
        }.to change { user.events.where(action: "email_verification_requested").count }.by(1)
      end

      it "creates email_verified event when verified changes to true" do
        user = create(:user, verified: false)
        expect {
          user.update!(verified: true)
        }.to change { user.events.where(action: "email_verified").count }.by(1)
      end

      it "does not create email_verified event when verified changes to false" do
        user = create(:user, verified: true)
        expect {
          user.update!(verified: false)
        }.not_to change { user.events.where(action: "email_verified").count }
      end

      it "deletes other sessions when password changes" do
        user = create(:user)
        session1 = user.sessions.create!
        session2 = user.sessions.create!
        Current.session = session1

        user.update!(password: SecureRandom.alphanumeric(20) + "!@#")

        expect(Session.find_by(id: session1.id)).to be_present
        expect(Session.find_by(id: session2.id)).to be_nil
      end
    end
  end

  describe "token generation" do
    it "generates email_verification token" do
      user = create(:user)
      token = user.generate_token_for(:email_verification)
      expect(token).to be_present
    end

    it "generates password_reset token" do
      user = create(:user)
      token = user.generate_token_for(:password_reset)
      expect(token).to be_present
    end

    it "can find user by email_verification token" do
      user = create(:user)
      token = user.generate_token_for(:email_verification)
      found_user = User.find_by_token_for(:email_verification, token)
      expect(found_user).to eq(user)
    end

    it "can find user by password_reset token" do
      user = create(:user)
      token = user.generate_token_for(:password_reset)
      found_user = User.find_by_token_for(:password_reset, token)
      expect(found_user).to eq(user)
    end
  end

  describe "password security" do
    it "has secure password" do
      user = create(:user)
      expect(user.password_digest).to be_present
      expect(user.password_digest).not_to eq(user.password)
    end

    it "authenticates with correct password" do
      user = create(:user)
      expect(user.authenticate(user.password)).to be_truthy
    end

    it "does not authenticate with incorrect password" do
      user = create(:user)
      expect(user.authenticate("wrongpassword")).to be false
    end
  end
end

