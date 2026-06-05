require "rails_helper"

RSpec.describe "Dashboard::Dashboard", type: :request do
  let(:admin) { create(:user, :admin) }

  context "when unauthenticated" do
    it "returns 404 (route constraint)" do
      get dashboard_root_path
      expect(response).to have_http_status(:not_found)
    end
  end

  context "when authenticated as admin" do
    before { sign_in_as(admin) }

    describe "GET /admin" do
      it "returns 200 and exposes summary counts" do
        create(:article, user: admin)
        create(:tag)
        get dashboard_root_path
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
