require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let(:user) { create(:user) }

  describe "POST /session" do
    context "with valid credentials" do
      it "creates a session and redirects to the admin dashboard" do
        expect {
          post session_path, params: { email_address: user.email_address, password: user.password }
        }.to change { user.sessions.count }.by(1)

        expect(response).to redirect_to(admin_dashboard_show_path)
      end
    end

    context "with invalid credentials" do
      it "redirects back to new with an alert" do
        post session_path, params: { email_address: user.email_address, password: "wrong" }

        expect(response).to redirect_to(new_session_path)
        follow_redirect!
        expect(response.body).to include("Try another email address or password.")
      end
    end
  end

  describe "DELETE /session" do
    it "terminates the session and redirects to the sign-in page" do
      # Create a real session via the controller so the test client receives the signed cookie
      post session_path, params: { email_address: user.email_address, password: user.password }
      expect(response).to redirect_to(admin_dashboard_show_path)

      s = user.sessions.reload.last
      expect(s).to be_present

      delete session_path

      expect(response).to redirect_to(new_session_path)
      # Controller uses status :see_other (303) for redirects on destroy
      expect(response.status).to eq(303)

      expect(Session.where(id: s.id)).to be_empty
    end
  end

  describe "GET /session" do
    it "redirects to root_path with status 303 (see_other)" do
      get session_path

      expect(response).to redirect_to(root_path)
      expect(response.status).to eq(303)
    end
  end
end
