require 'rails_helper'

RSpec.describe "Admin::Dashboards", type: :request do
  describe "GET /show" do
    let(:user) { create(:user) }

    context "when signed in as admin" do
      it "returns http success" do
        sign_in_as(user)

        get admin_dashboard_show_path
        expect(response).to have_http_status(:success)
      end
    end

    context "when not signed in" do
      it "redirects to sign in" do
        get admin_dashboard_show_path
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
