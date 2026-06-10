require "rails_helper"

RSpec.describe OgImageGenerationJob, type: :job do
  let(:article) { create(:article, :published) }
  let(:fake_result) do
    OgImageService::Result.new(
      bytes:        "fake-jpeg-bytes",
      content_type: "image/jpeg"
    )
  end

  before do
    allow(OgImageService).to receive(:call).and_return(fake_result)
  end

  describe "#perform" do
    it "attaches og_image to the article" do
      expect {
        described_class.perform_now(article.id)
      }.to change { article.reload.og_image.attached? }.from(false).to(true)
    end

    it "calls OgImageService with the article image bytes and title" do
      expected_bytes = article.image.download

      described_class.perform_now(article.id)

      expect(OgImageService).to have_received(:call).with(
        image_bytes: expected_bytes,
        title:       article.title
      )
    end

    it "names the file using the article slug" do
      described_class.perform_now(article.id)

      expect(article.reload.og_image.filename.to_s).to eq("og-#{article.slug}.jpg")
    end

    it "does nothing when the article does not exist" do
      expect { described_class.perform_now(-1) }.not_to raise_error
      expect(OgImageService).not_to have_received(:call)
    end

    it "does nothing when the article has no image attached" do
      article.image.detach

      described_class.perform_now(article.id)

      expect(OgImageService).not_to have_received(:call)
    end

    it "re-raises Vips::Error so ActiveJob can retry" do
      allow(OgImageService).to receive(:call).and_raise(Vips::Error, "vips boom")

      expect { described_class.perform_now(article.id) }.to raise_error(Vips::Error)
    end

    it "logs the Vips::Error before re-raising" do
      allow(OgImageService).to receive(:call).and_raise(Vips::Error, "vips boom")
      allow(Rails.logger).to receive(:error)

      expect { described_class.perform_now(article.id) }.to raise_error(Vips::Error)
      expect(Rails.logger).to have_received(:error).with(/OgImageGenerationJob.*#{article.id}/)
    end
  end
end