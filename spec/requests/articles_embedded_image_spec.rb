require 'rails_helper'

# Specs covering the model validation that blocks saving an article whose
# rich-text body contains unresolvable (MissingAttachable) attachment nodes —
# e.g. when a user pastes markdown containing inline images.
#
# The no_missing_attachments_in_content validator fires on both create and
# update, re-rendering the form with a clear error message instead of saving
# and then 500-ing on the show page.

RSpec.describe "Embedded image safeguards", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:tag)   { create(:tag) }
  let(:image_file) do
    Rack::Test::UploadedFile.new(
      Rails.root.join("spec", "fixtures", "files", "test_image.jpg"),
      "image/jpeg"
    )
  end

  # ---------------------------------------------------------------------------
  # POST /articles — create blocked by model validation
  # ---------------------------------------------------------------------------
  describe "POST /articles with MissingAttachable content" do
    it "does not create the article and re-renders the form with a content error" do
      sign_in_as(admin)

      # Stub the model validation to simulate what happens when pasted markdown
      # with an embedded image produces a MissingAttachable node.
      allow_any_instance_of(Article).to receive(:no_missing_attachments_in_content) do |article|
        article.errors.add(
          :content,
          "contains an embedded image that could not be processed. " \
          "Please remove inline images from your pasted content and use " \
          "the image upload button instead."
        )
      end

      expect {
        post articles_url, params: {
          article: {
            title: "Pasted Markdown Article",
            content: "Text with ![broken](http://external.example.com/img.png)",
            tag_ids: [tag.id],
            image: image_file
          }
        }
      }.not_to change(Article, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("embedded image that could not be processed")
    end
  end

  # ---------------------------------------------------------------------------
  # PATCH /articles/:id — update blocked by model validation
  # ---------------------------------------------------------------------------
  describe "PATCH /articles/:id with MissingAttachable content" do
    it "does not update the article and re-renders the form with a content error" do
      article = create(:article, user: admin, tags: [tag])
      sign_in_as(admin)

      allow_any_instance_of(Article).to receive(:no_missing_attachments_in_content) do |a|
        a.errors.add(
          :content,
          "contains an embedded image that could not be processed. " \
          "Please remove inline images from your pasted content and use " \
          "the image upload button instead."
        )
      end

      patch article_url(article), params: {
        article: {
          title: article.title,
          content: "Updated with ![broken](http://external.example.com/img.png)"
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("embedded image that could not be processed")
    end
  end
end
