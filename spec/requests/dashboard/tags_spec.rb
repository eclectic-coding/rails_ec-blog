require "rails_helper"

RSpec.describe "Dashboard::Tags", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:tag) { create(:tag) }

  context "when unauthenticated" do
    it "returns 404 for all actions (route constraint)" do
      get dashboard_tags_path
      expect(response).to have_http_status(:not_found)
    end
  end

  context "when authenticated as admin" do
    before { sign_in_as(admin) }

    it "updates the tag and redirects to show" do
      patch dashboard_tag_path(tag), params: { tag: { name: "updated" } }
      expect(tag.reload.name).to eq("updated")
      expect(response).to redirect_to(dashboard_tag_path(tag))
    end

    it "renders edit with 422 on invalid params" do
      patch dashboard_tag_path(tag), params: { tag: { name: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "renders new with 422 on duplicate tag name" do
      tag
      post dashboard_tags_path, params: { tag: { name: tag.name } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end