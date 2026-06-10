require "rails_helper"

RSpec.describe OgImageService do
  let(:image_bytes) do
    band = Vips::Image.black(800, 600)
    band.bandjoin([band, band]).copy(interpretation: :srgb).write_to_buffer(".jpg")
  end
  let(:title) { "My Test Article Title" }

  shared_context "pango available" do
    before do
      Vips::Image.text("x", font: "Sans 12", width: 100, dpi: 72)
    rescue Vips::Error
      skip "pango not available on this system"
    end
  end

  describe ".call" do
    subject(:result) { described_class.call(image_bytes: image_bytes, title: title) }

    it "returns a Result with JPEG bytes" do
      expect(result.content_type).to eq("image/jpeg")
      expect(result.bytes).not_to be_empty
    end

    it "outputs an image exactly 1200×630 pixels" do
      output = Vips::Image.new_from_buffer(result.bytes, "")
      expect(output.width).to eq(1200)
      expect(output.height).to eq(630)
    end

    context "when title is empty" do
      let(:title) { "" }

      it "still returns a valid 1200×630 JPEG without raising" do
        output = Vips::Image.new_from_buffer(result.bytes, "")
        expect(output.width).to eq(1200)
        expect(output.height).to eq(630)
      end
    end

    context "when title is very long" do
      include_context "pango available"
      let(:title) { "A" * 200 }

      it "returns a valid 1200×630 JPEG without raising" do
        output = Vips::Image.new_from_buffer(result.bytes, "")
        expect(output.width).to eq(1200)
        expect(output.height).to eq(630)
      end
    end

    context "with a portrait source image" do
      let(:image_bytes) do
        band = Vips::Image.black(400, 800)
        band.bandjoin([band, band]).copy(interpretation: :srgb).write_to_buffer(".jpg")
      end

      it "crops and fills to 1200×630 without raising" do
        output = Vips::Image.new_from_buffer(result.bytes, "")
        expect(output.width).to eq(1200)
        expect(output.height).to eq(630)
      end
    end

    context "with a landscape source image" do
      let(:image_bytes) do
        band = Vips::Image.black(2400, 400)
        band.bandjoin([band, band]).copy(interpretation: :srgb).write_to_buffer(".jpg")
      end

      it "crops and fills to 1200×630 without raising" do
        output = Vips::Image.new_from_buffer(result.bytes, "")
        expect(output.width).to eq(1200)
        expect(output.height).to eq(630)
      end
    end

    context "when title is whitespace only" do
      let(:title) { "   " }

      it "treats it as empty and does not raise" do
        expect { result }.not_to raise_error
      end
    end
  end
end
