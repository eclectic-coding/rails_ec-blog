require 'rails_helper'

RSpec.describe "Admin::Dashboards", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/admin/dashboard/show"
      expect(response).to have_http_status(:success)
    end
  end

end
