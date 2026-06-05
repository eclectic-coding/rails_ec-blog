require "rails_helper"

RSpec.describe "Madmin dashboard", type: :request do
  describe "GET /admin" do
    context "when unauthenticated" do
      it "returns 404 (route constraint blocks the request)" do
        get madmin_root_path
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when authenticated as a non-admin" do
      it "returns 404 (route constraint blocks the request)" do
        sign_in_as(create(:user))
        get madmin_root_path
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when authenticated as admin" do
      it "returns 200 OK" do
        sign_in_as(create(:user, :admin))
        get madmin_root_path
        expect(response).to have_http_status(:ok)
      end
    end
  end
end