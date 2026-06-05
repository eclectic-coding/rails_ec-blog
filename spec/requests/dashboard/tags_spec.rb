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

    describe "GET /admin/tags" do
      it "returns 200" do
        tag
        get dashboard_tags_path
        expect(response).to have_http_status(:ok)
      end
    end

    describe "GET /admin/tags/:id" do
      it "returns 200" do
        get dashboard_tag_path(tag)
        expect(response).to have_http_status(:ok)
      end
    end

    describe "GET /admin/tags/new" do
      it "returns 200" do
        get new_dashboard_tag_path
        expect(response).to have_http_status(:ok)
      end
    end

    describe "GET /admin/tags/:id/edit" do
      it "returns 200" do
        get edit_dashboard_tag_path(tag)
        expect(response).to have_http_status(:ok)
      end
    end

    describe "POST /admin/tags" do
      it "creates a tag and redirects to show" do
        expect {
          post dashboard_tags_path, params: { tag: { name: "newtag" } }
        }.to change(Tag, :count).by(1)
        expect(response).to redirect_to(dashboard_tag_path(Tag.last))
      end

      it "renders new with 422 on invalid params" do
        post dashboard_tags_path, params: { tag: { name: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders new with 422 on duplicate name" do
        tag
        post dashboard_tags_path, params: { tag: { name: tag.name } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    describe "PATCH /admin/tags/:id" do
      it "updates the tag and redirects to show" do
        patch dashboard_tag_path(tag), params: { tag: { name: "updated" } }
        expect(tag.reload.name).to eq("updated")
        expect(response).to redirect_to(dashboard_tag_path(tag))
      end

      it "renders edit with 422 on invalid params" do
        patch dashboard_tag_path(tag), params: { tag: { name: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    describe "DELETE /admin/tags/:id" do
      it "destroys the tag and redirects to index" do
        tag
        expect {
          delete dashboard_tag_path(tag)
        }.to change(Tag, :count).by(-1)
        expect(response).to redirect_to(dashboard_tags_path)
      end
    end
  end
end