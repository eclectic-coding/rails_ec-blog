require "rails_helper"

RSpec.describe "Madmin::Articles", type: :request do
  let(:admin) { create(:user, :admin) }

  let(:valid_params) do
    tag = create(:tag)
    {
      title: "Admin Article",
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

  describe "POST /admin/articles" do
    context "with valid parameters" do
      it "creates the article assigned to the current admin" do
        sign_in_as(admin)
        expect {
          post madmin_articles_path, params: { article: valid_params }
        }.to change(Article, :count).by(1)
        expect(Article.last.user_id).to eq(admin.id)
      end

      it "redirects to the article show page" do
        sign_in_as(admin)
        post madmin_articles_path, params: { article: valid_params }
        expect(response).to redirect_to(madmin_article_path(Article.last))
      end
    end

    context "with invalid parameters" do
      it "does not create an article" do
        sign_in_as(admin)
        expect {
          post madmin_articles_path, params: { article: invalid_params }
        }.not_to change(Article, :count)
      end

      it "renders new with 422" do
        sign_in_as(admin)
        post madmin_articles_path, params: { article: invalid_params }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end