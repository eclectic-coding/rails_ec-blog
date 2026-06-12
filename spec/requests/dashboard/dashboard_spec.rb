require "rails_helper"

RSpec.describe "Dashboard::Dashboard", type: :request do
  context "when unauthenticated" do
    it "returns 404 (route constraint)" do
      get dashboard_root_path
      expect(response).to have_http_status(:not_found)
    end
  end
end