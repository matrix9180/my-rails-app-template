require "rails_helper"

RSpec.describe Admin::Users::AvatarsController, type: :request do
  let(:admin_user) { create(:user, role: :admin) }
  let(:target_user) { create(:user, role: :user, username: "targetuser", email: "target@example.com") }

  describe "GET #show" do
    before do
      sign_in_as admin_user
    end
    context "when user has an avatar" do
      before do
        # Attach a test image
        target_user.avatar.attach(
          io: File.open(Rails.root.join("spec/fixtures/files/test_image.jpg")),
          filename: "test_image.jpg",
          content_type: "image/jpeg"
        )
      end

      it "should get show" do
        get admin_user_avatar_url(target_user.username)
        expect(response).to have_http_status(:success)
      end

      it "should display avatar image" do
        get admin_user_avatar_url(target_user.username)
        expect(response.body).to include("test_image.jpg")
      end

      it "should display avatar details" do
        get admin_user_avatar_url(target_user.username)
        expect(response.body).to include("Avatar Details")
        expect(response.body).to include(target_user.avatar.filename.to_s)
        expect(response.body).to include(target_user.avatar.content_type)
      end

      it "should display file size" do
        get admin_user_avatar_url(target_user.username)
        expect(response.body).to include("File Size")
      end

      it "should display uploaded date" do
        get admin_user_avatar_url(target_user.username)
        expect(response.body).to include("Uploaded At")
      end

      it "should find user by username (case insensitive)" do
        get admin_user_avatar_url(target_user.username.upcase)
        expect(response).to have_http_status(:success)
      end
    end

    context "when user has no avatar" do
      it "should show message when user has no avatar" do
        get admin_user_avatar_url(target_user.username)
        expect(response.body).to include("no avatar")
      end
    end
  end

  describe "DELETE #destroy" do
    before do
      sign_in_as admin_user
    end
    context "when user has an avatar" do
      before do
        target_user.avatar.attach(
          io: File.open(Rails.root.join("spec/fixtures/files/test_image.jpg")),
          filename: "test_image.jpg",
          content_type: "image/jpeg"
        )
      end

      it "should delete the avatar" do
        expect(target_user.avatar.attached?).to be true
        delete admin_user_avatar_url(target_user.username)
        expect(target_user.reload.avatar.attached?).to be false
      end

      it "should redirect to user show page after deletion" do
        delete admin_user_avatar_url(target_user.username)
        expect(response).to redirect_to(admin_user_url(target_user.username))
      end

      it "should show success notice after deletion" do
        delete admin_user_avatar_url(target_user.username)
        expect(flash[:notice]).to be_present
      end
    end

    context "when user has no avatar" do
      it "should handle deletion gracefully" do
        expect(target_user.avatar.attached?).to be false
        delete admin_user_avatar_url(target_user.username)
        expect(response).to redirect_to(admin_user_url(target_user.username))
        expect(flash[:notice]).to be_present
      end
    end
  end

  describe "authorization" do
    context "when user is not an admin" do
      let(:regular_user) { create(:user, role: :user) }

      before do
        sign_in_as regular_user
      end

      it "should not allow access to avatar show" do
        get admin_user_avatar_url(target_user.username)
        expect(response).to redirect_to(root_url)
      end

      it "should not allow destroying avatar" do
        target_user.avatar.attach(
          io: File.open(Rails.root.join("spec/fixtures/files/test_image.jpg")),
          filename: "test_image.jpg",
          content_type: "image/jpeg"
        )
        delete admin_user_avatar_url(target_user.username)
        expect(response).to redirect_to(root_url)
        expect(target_user.reload.avatar.attached?).to be true
      end
    end

    context "when user is not signed in" do
      it "should redirect to sign in" do
        get admin_user_avatar_url(target_user.username)
        expect(response).to redirect_to(sign_in_url)
      end
    end
  end
end
