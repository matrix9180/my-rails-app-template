require "rails_helper"

RSpec.describe Admin::UsersController, type: :request do
  let(:admin_user) { create(:user, role: :admin) }
  let(:regular_user) { create(:user, role: :user) }
  let(:other_user) { create(:user, role: :user, username: "otheruser", email: "other@example.com") }

  before do
    sign_in_as admin_user
  end

  describe "GET #index" do
    it "should get index" do
      get admin_users_url
      expect(response).to have_http_status(:success)
    end

    it "should list all users" do
      regular_user
      other_user
      get admin_users_url
      expect(response.body).to include(regular_user.username)
      expect(response.body).to include(other_user.username)
    end

    it "should order users by created_at desc" do
      old_user = create(:user, created_at: 2.days.ago)
      new_user = create(:user, created_at: 1.day.ago)
      get admin_users_url
      expect(response.body).to match(/#{new_user.username}.*#{old_user.username}/m)
    end

    context "with search parameter" do
      it "should filter users by username" do
        create(:user, username: "john_doe", email: "john@example.com")
        create(:user, username: "jane_smith", email: "jane@example.com")
        get admin_users_url, params: { search: "john" }
        expect(response.body).to include("john_doe")
        expect(response.body).not_to include("jane_smith")
      end

      it "should filter users by email" do
        create(:user, username: "user1", email: "john@example.com")
        create(:user, username: "user2", email: "jane@example.com")
        get admin_users_url, params: { search: "john@example.com" }
        expect(response.body).to include("user1")
        expect(response.body).not_to include("user2")
      end

      it "should be case insensitive" do
        user = create(:user, username: "JohnDoe", email: "john@example.com")
        get admin_users_url, params: { search: "johndoe" }
        # Username is normalized to lowercase in the database
        expect(response.body).to include(user.username.downcase)
      end
    end

    context "with role filter" do
      it "should filter users by role" do
        admin1 = create(:user, role: :admin)
        regular1 = create(:user, role: :user)
        get admin_users_url, params: { role: "admin" }
        expect(response.body).to include(admin1.username)
        expect(response.body).not_to include(regular1.username)
      end
    end

    context "with pagination" do
      it "should paginate users" do
        30.times { create(:user) }
        get admin_users_url
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET #show" do
    it "should get show" do
      get admin_user_url(other_user.username)
      expect(response).to have_http_status(:success)
    end

    it "should display user information" do
      get admin_user_url(other_user.username)
      expect(response.body).to include(other_user.username)
      expect(response.body).to include(other_user.email)
    end

    it "should display user statistics" do
      get admin_user_url(other_user.username)
      expect(response.body).to include("Active Sessions")
      expect(response.body).to include("Total Events")
    end

    it "should find user by username (case insensitive)" do
      get admin_user_url(other_user.username.upcase)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #edit" do
    it "should get edit" do
      get edit_admin_user_url(other_user.username)
      expect(response).to have_http_status(:success)
    end

    it "should display edit form" do
      get edit_admin_user_url(other_user.username)
      expect(response.body).to include(other_user.username)
      expect(response.body).to include(other_user.email)
    end
  end

  describe "PATCH #update" do
    context "with valid parameters" do
      it "should update user email" do
        patch admin_user_url(other_user.username), params: { user: { email: "newemail@example.com" } }
        expect(response).to redirect_to(admin_user_url(other_user.reload.username))
        expect(other_user.reload.email).to eq("newemail@example.com")
      end

      it "should update user username" do
        patch admin_user_url(other_user.username), params: { user: { username: "newname" } }
        expect(response).to redirect_to(admin_user_url("newname"))
        expect(other_user.reload.username).to eq("newname")
      end

      it "should update user role" do
        patch admin_user_url(other_user.username), params: { user: { role: "admin" } }
        expect(response).to redirect_to(admin_user_url(other_user.username))
        expect(other_user.reload.role).to eq("admin")
      end

      it "should not allow admin to change their own role" do
        original_role = admin_user.role
        patch admin_user_url(admin_user.username), params: { user: { role: "user" } }
        expect(response).to redirect_to(admin_user_url(admin_user.username))
        expect(admin_user.reload.role).to eq(original_role)
      end

      it "should update verified status" do
        other_user.update!(verified: false)
        patch admin_user_url(other_user.username), params: { user: { verified: true } }
        expect(response).to redirect_to(admin_user_url(other_user.username))
        expect(other_user.reload.verified).to be true
      end

      it "should show success notice" do
        patch admin_user_url(other_user.username), params: { user: { email: "newemail@example.com" } }
        expect(flash[:notice]).to be_present
      end
    end

    context "with invalid parameters" do
      it "should render edit on validation error" do
        allow_any_instance_of(User).to receive(:update).and_return(false)
        patch admin_user_url(other_user.username), params: { user: { email: "invalid" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE #destroy" do
    it "should delete user" do
      user_to_delete = create(:user)
      expect {
        delete admin_user_url(user_to_delete.username)
      }.to change(User, :count).by(-1)
    end

    it "should redirect to users index after deletion" do
      user_to_delete = create(:user)
      delete admin_user_url(user_to_delete.username)
      expect(response).to redirect_to(admin_users_url)
    end

    it "should show success notice after deletion" do
      user_to_delete = create(:user)
      delete admin_user_url(user_to_delete.username)
      expect(flash[:notice]).to be_present
    end

    it "should not allow admin to delete themselves" do
      expect {
        delete admin_user_url(admin_user.username)
      }.not_to change(User, :count)
    end

    it "should show alert when trying to delete self" do
      delete admin_user_url(admin_user.username)
      expect(response).to redirect_to(admin_users_url)
      expect(flash[:alert]).to be_present
    end
  end

  describe "authorization" do
    context "when user is not an admin" do
      before do
        sign_in_as regular_user
      end

      it "should not allow access to index" do
        get admin_users_url
        expect(response).to redirect_to(root_url)
      end

      it "should not allow access to show" do
        get admin_user_url(other_user.username)
        expect(response).to redirect_to(root_url)
      end

      it "should not allow access to edit" do
        get edit_admin_user_url(other_user.username)
        expect(response).to redirect_to(root_url)
      end

      it "should not allow update" do
        patch admin_user_url(other_user.username), params: { user: { email: "hacked@example.com" } }
        expect(response).to redirect_to(root_url)
        expect(other_user.reload.email).not_to eq("hacked@example.com")
      end

      it "should not allow destroy" do
        # Ensure other_user is created before checking count
        other_user
        initial_count = User.count
        delete admin_user_url(other_user.username)
        expect(User.count).to eq(initial_count)
        expect(response).to redirect_to(root_url)
      end
    end
  end
end
