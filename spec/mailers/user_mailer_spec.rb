require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  let(:user) { create(:user) }

  describe "#password_reset" do
    it "sends password reset email" do
      mail = UserMailer.with(user: user).password_reset
      expect(mail.subject).to eq("Reset your password")
      expect(mail.to).to eq([ user.email ])
    end
  end

  describe "#email_verification" do
    it "sends email verification email" do
      mail = UserMailer.with(user: user).email_verification
      expect(mail.subject).to eq("Verify your email")
      expect(mail.to).to eq([ user.email ])
    end
  end

  describe "#passwordless" do
    it "sends passwordless sign in email" do
      mail = UserMailer.with(user: user).passwordless
      expect(mail.subject).to eq("Your sign in link")
      expect(mail.to).to eq([ user.email ])
    end
  end
end
