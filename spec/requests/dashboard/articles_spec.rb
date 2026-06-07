require "rails_helper"

RSpec.describe "Dashboard::Articles", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:article) { create(:article, user: admin) }

  let(:valid_params) do
    tag = create(:tag)
    {
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
  end

  let(:invalid_params) { { title: "", content: "" } }

  context "when unauthenticated" do
    it "returns 404 for all actions (route constraint)" do
      get dashboard_articles_path
      expect(response).to have_http_status(:not_found)
    end
  end

  context "when authenticated as admin" do
    before { sign_in_as(admin) }

    describe "GET /admin/articles" do
      it "returns 200" do
        article
        get dashboard_articles_path
        expect(response).to have_http_status(:ok)
      end
    end

    describe "GET /admin/articles/:id" do
      it "returns 200" do
        get dashboard_article_path(article)
        expect(response).to have_http_status(:ok)
      end
    end

    describe "GET /admin/articles/new" do
      it "returns 200" do
        get new_dashboard_article_path
        expect(response).to have_http_status(:ok)
      end
    end

    describe "GET /admin/articles/:id/edit" do
      it "returns 200" do
        get edit_dashboard_article_path(article)
        expect(response).to have_http_status(:ok)
      end
    end

    describe "POST /admin/articles" do
      it "creates article assigned to the current admin" do
        expect {
          post dashboard_articles_path, params: { article: valid_params }
        }.to change(Article, :count).by(1)
        expect(Article.last.user).to eq(admin)
      end

      it "redirects to the dashboard show page on success" do
        post dashboard_articles_path, params: { article: valid_params }
        expect(response).to redirect_to(dashboard_article_path(Article.last))
      end

      it "renders new with 422 on invalid params" do
        post dashboard_articles_path, params: { article: invalid_params }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    describe "PATCH /admin/articles/:id" do
      it "updates the article and redirects to dashboard show" do
        patch dashboard_article_path(article), params: { article: { title: "Updated" } }
        expect(article.reload.title).to eq("Updated")
        expect(response).to redirect_to(dashboard_article_path(article))
      end

      it "renders edit with 422 on invalid params" do
        patch dashboard_article_path(article), params: { article: { title: "" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    it "purges the image when remove_image is set and image is attached" do
      patch dashboard_article_path(article), params: { article: { remove_image: "1" } }
      expect(article.reload.image.attached?).to be(false)
      expect(flash[:notice]).to include("Image removed")
    end

    it "notices no image when remove_image is set but no image is attached" do
      article.image.purge
      patch dashboard_article_path(article), params: { article: { remove_image: "1" } }
      expect(flash[:notice]).to include("No image was attached")
    end

    describe "DELETE /admin/articles/:id" do
      it "destroys the article and redirects to dashboard index" do
        article
        expect {
          delete dashboard_article_path(article)
        }.to change(Article, :count).by(-1)
        expect(response).to redirect_to(dashboard_articles_path)
      end

      it "responds with turbo stream that removes the row" do
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
end
