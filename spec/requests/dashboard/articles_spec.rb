require "rails_helper"

RSpec.describe "Dashboard::Articles", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:article) { create(:article, user: admin) }

  context "when unauthenticated" do
    it "returns 404 for all actions (route constraint)" do
      get dashboard_articles_path
      expect(response).to have_http_status(:not_found)
    end
  end

  context "when authenticated as admin" do
    before { sign_in_as(admin) }

    it "sanitises unrecognised sort params rather than passing them to SQL" do
      get dashboard_articles_path(sort: "injected_sql", direction: "evil")
      expect(response).to have_http_status(:ok)
    end

    it "creates article assigned to the current admin" do
      tag = create(:tag)
      valid_params = {
        title: "Dashboard Article",
        content: "Body text.",
        is_published: true,
        published_at: Time.current.to_s,
        tag_ids: [tag.id],
        image: Rack::Test::UploadedFile.new(
          Rails.root.join("spec", "fixtures", "files", "test_image.jpg"),
          "image/jpeg"
        )
      }
      post dashboard_articles_path, params: { article: valid_params }
      expect(Article.last.user).to eq(admin)
    end

    it "renders edit with 422 on invalid params" do
      patch dashboard_article_path(article), params: { article: { title: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "purges the image and notices success when remove_image is set" do
      patch dashboard_article_path(article), params: { article: { remove_image: "1" } }
      expect(article.reload.image.attached?).to be(false)
      expect(flash[:notice]).to include("Image removed")
    end

    it "notices no image when remove_image is set but no image is attached" do
      article.image.purge
      patch dashboard_article_path(article), params: { article: { remove_image: "1" } }
      expect(flash[:notice]).to include("No image was attached")
    end

    it "responds with a turbo stream that removes the row on delete" do
      article
      expect {
        delete dashboard_article_path(article), headers: { "Accept" => "text/vnd.turbo-stream.html" }
      }.to change(Article, :count).by(-1)
      expect(response).to have_turbo_stream
        .with_action(:remove)
        .targeting(ActionView::RecordIdentifier.dom_id(article))
    end
  end
end