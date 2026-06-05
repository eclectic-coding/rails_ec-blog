require "rails_helper"

RSpec.describe "Dashboard::Sessions", type: :request do
  let(:admin) { create(:user, :admin) }

  context "when unauthenticated" do
    it "returns 404 for destroy (route constraint)" do
      other_session = admin.sessions.create!
      delete dashboard_session_path(other_session)
      expect(response).to have_http_status(:not_found)
    end
  end

  context "when authenticated as admin" do
    before { sign_in_as(admin) }

    describe "DELETE /admin/sessions/:id" do
      it "destroys a non-current session and redirects to user show" do
        other_session = admin.sessions.create!(ip_address: "1.2.3.4", user_agent: "TestAgent")
        expect {
          delete dashboard_session_path(other_session)
        }.to change(Session, :count).by(-1)
        expect(response).to redirect_to(dashboard_user_path(admin))
      end

      it "can destroy the current session" do
        current = Current.session
        expect {
          delete dashboard_session_path(current)
        }.to change(Session, :count).by(-1)
        expect(response).to redirect_to(dashboard_user_path(admin))
      end
    end
  end
end
