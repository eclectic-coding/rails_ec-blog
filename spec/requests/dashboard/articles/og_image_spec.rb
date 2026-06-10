require "rails_helper"

RSpec.describe "Dashboard::Articles::OgImage", type: :request do
  let(:admin)   { create(:user, :admin) }
  let(:article) { create(:article, :published, user: admin) }

  context "when unauthenticated" do
    it "returns 404 (route constraint)" do
      post dashboard_article_og_image_path(article)
      expect(response).to have_http_status(:not_found)
    end
  end

  context "when authenticated as admin" do
    before { sign_in_as(admin) }

    describe "POST /admin/articles/:article_id/og_image" do
      before do
        allow(OgImageGenerationJob).to receive(:perform_now)
      end

      it "calls OgImageGenerationJob synchronously" do
        post dashboard_article_og_image_path(article)
        expect(OgImageGenerationJob).to have_received(:perform_now).with(article.id)
      end

      it "responds with turbo stream when requested" do
        post dashboard_article_og_image_path(article),
             headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(response.content_type).to include("turbo-stream")
        expect(response.body).to include("og-card-#{article.id}")
      end

      it "redirects to article show on html request" do
        post dashboard_article_og_image_path(article)
        expect(response).to redirect_to(dashboard_article_path(article))
      end
    end
  end
end
