require "rails_helper"

RSpec.describe "Madmin dashboard", type: :request do
  describe "GET /admin" do
    context "when unauthenticated" do
      it "redirects to the sign-in page" do
        get madmin_root_path
        expect(response).to redirect_to(new_session_path)
      end
    end

    context "when authenticated as a non-admin" do
      it "redirects to root with an authorization alert" do
        sign_in_as(create(:user))
        get madmin_root_path
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("Not authorized.")
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