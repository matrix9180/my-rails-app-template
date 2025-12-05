require "rails_helper"

RSpec.describe Admin::BaseController, type: :request do
  let(:admin_user) { create(:user, role: :admin) }
  let(:regular_user) { create(:user, role: :user) }

  describe "authorization" do
    context "when user is not signed in" do
      it "should redirect to sign in page" do
        get admin_users_url
        expect(response).to redirect_to(sign_in_url)
      end
    end

    context "when user is not an admin" do
      before do
        sign_in_as regular_user
      end

      it "should redirect to root with alert" do
        get admin_users_url
        expect(response).to redirect_to(root_url)
        expect(flash[:alert]).to be_present
      end
    end

    context "when user is an admin" do
      before do
        sign_in_as admin_user
      end

      it "should allow access to admin pages" do
        get admin_users_url
        expect(response).to have_http_status(:success)
      end
    end
  end
end
