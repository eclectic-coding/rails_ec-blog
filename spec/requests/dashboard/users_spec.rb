require "rails_helper"

RSpec.describe "Dashboard::Users", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user) }

  context "when unauthenticated" do
    it "returns 404 for all actions (route constraint)" do
      get dashboard_users_path
      expect(response).to have_http_status(:not_found)
    end
  end

  context "when authenticated as admin" do
    before { sign_in_as(admin) }

    it "promotes a user to admin" do
      patch dashboard_user_path(user), params: { user: { admin: true } }
      expect(user.reload.admin?).to be(true)
    end

    it "updates password when provided" do
      patch dashboard_user_path(user), params: { user: { password: "newpassword", password_confirmation: "newpassword" } }
      expect(response).to redirect_to(dashboard_user_path(user))
    end

    it "does not change password when fields are blank" do
      old_digest = user.password_digest
      patch dashboard_user_path(user), params: { user: { email_address: user.email_address, password: "", password_confirmation: "" } }
      expect(user.reload.password_digest).to eq(old_digest)
    end
  end
end