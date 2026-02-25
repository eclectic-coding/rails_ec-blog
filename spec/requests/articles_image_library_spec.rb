require 'rails_helper'

RSpec.describe "GET /articles/image_library", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:user)  { create(:user) }
  let(:fixture_path) { Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg') }

  def attach_image(article)
    article.image.attach(
      io: File.open(fixture_path),
      filename: 'test_image.jpg',
      content_type: 'image/jpeg'
    )
    article.save!
    article
  end

  # ── Access control ────────────────────────────────────────────────────────

  context "when unauthenticated" do
    it "redirects to the sign-in page" do
      get image_library_articles_path
      expect(response).to redirect_to(new_session_path)
    end
  end

  context "when authenticated as a non-admin" do
    it "redirects to root with an authorization alert" do
      sign_in_as(user)
      get image_library_articles_path
      expect(response).to redirect_to(root_path)
    end
  end

  # ── Happy path ────────────────────────────────────────────────────────────

  context "when authenticated as admin" do
    before { sign_in_as(admin) }

    it "returns 200 OK" do
      get image_library_articles_path
      expect(response).to have_http_status(:ok)
    end

    it "renders the turbo-frame wrapper" do
      get image_library_articles_path
      expect(response.body).to include('id="image-library-frame"')
    end

    context "with no article images uploaded" do
      it "shows the empty-state message" do
        get image_library_articles_path
        expect(response.body).to include("No images uploaded yet")
      end
    end

    context "with article images uploaded" do
      let!(:article_with_image) { attach_image(create(:article, user: user)) }

      it "renders a tile for each uploaded blob" do
        get image_library_articles_path
        expect(response.body).to include("test_image.jpg")
      end

      it "includes signed-id and filename data attributes on each tile" do
        get image_library_articles_path
        expect(response.body).to include("data-blob-signed-id=")
        expect(response.body).to include('data-blob-filename="test_image.jpg"')
      end

      it "includes the Stimulus selectExisting action on each tile" do
        get image_library_articles_path
        expect(response.body).to include("image-picker#selectExisting")
      end

      it "does not show duplicate blobs when the same image is reused across articles" do
        # Re-attach the same blob to a second article via signed ID
        second_article = create(:article, user: user)
        blob = article_with_image.image.blob
        second_article.image.attach(blob)
        second_article.save!

        get image_library_articles_path

        # Only one tile per unique blob — count the data attribute, not all occurrences
        # (the signed_id also appears in the <img src> URL, so raw scan would give > 1)
        tile_count = response.body.scan("data-blob-signed-id=\"#{blob.signed_id}\"").length
        expect(tile_count).to eq(1)
      end

      it "orders blobs newest first" do
        older = attach_image(create(:article, user: user))
        newer = attach_image(create(:article, user: user))

        older_blob = older.image.blob
        newer_blob = newer.image.blob

        get image_library_articles_path

        older_pos = response.body.index(older_blob.signed_id)
        newer_pos = response.body.index(newer_blob.signed_id)

        # newer blob should appear earlier in the HTML
        expect(newer_pos).to be < older_pos
      end
    end
  end
end

