require "rails_helper"

RSpec.describe HomeController, type: :request do
  let(:user) { create(:user) }

  before do
    sign_in_as user
  end

  describe "GET /" do
    it "should get index" do
      get root_url
      expect(response).to have_http_status(:success)
    end
  end
end
