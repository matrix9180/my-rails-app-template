require "rails_helper"

RSpec.describe ProfilesController, type: :request do
  let(:user) { create(:user) }

  before do
    sign_in_as user
  end

  describe "GET /profile/edit" do
    context "without sudo" do
      it "should redirect to sudo page" do
        travel 31.minutes
        get edit_my_profile_url
        expect(response).to redirect_to(new_sessions_sudo_path(proceed_to_url: edit_my_profile_url))
      end
    end

    context "with sudo" do
      it "should get edit" do
        get edit_my_profile_url
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PATCH /profile" do
    context "without sudo" do
      it "should redirect to sudo page" do
        travel 31.minutes
        patch update_my_profile_url, params: { user: { bio: "New bio" } }
        expect(response).to redirect_to(new_sessions_sudo_path(proceed_to_url: update_my_profile_url))
      end
    end

    context "with sudo" do
      it "should update profile with bio" do
        patch update_my_profile_url, params: { user: { bio: "This is my bio" } }
        expect(response).to redirect_to(my_profile_path)
        expect(user.reload.bio.to_plain_text).to eq("This is my bio")
      end

      it "should render edit on validation error" do
        allow_any_instance_of(User).to receive(:update).and_return(false)
        patch update_my_profile_url, params: { user: { bio: "Test" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /profile/avatar" do
    context "without sudo" do
      it "should redirect to sudo page" do
        travel 31.minutes
        avatar = fixture_file_upload("test_image.jpg", "image/jpeg")
        patch update_my_profile_avatar_url, params: { user: { avatar: avatar } }
        expect(response).to redirect_to(new_sessions_sudo_path(proceed_to_url: update_my_profile_avatar_url))
      end
    end

    context "with sudo" do
      it "should update profile with avatar" do
        avatar = fixture_file_upload("test_image.jpg", "image/jpeg")
        patch update_my_profile_avatar_url, params: { user: { avatar: avatar } }
        expect(response).to redirect_to(edit_my_profile_path)
        expect(user.reload.avatar).to be_attached
      end
    end
  end
end
