class OgImageService
  OG_WIDTH       = 1200
  OG_HEIGHT      = 630
  IMAGE_HEIGHT   = 420  # top ~2/3: photo area, fully visible
  BAND_HEIGHT    = OG_HEIGHT - IMAGE_HEIGHT  # bottom ~1/3: solid text area
  BAND_COLOR     = [24.0, 24.0, 24.0].freeze
  TEXT_MAX_WIDTH = 1100
  FONT_SPEC      = "DejaVu Sans Bold 48"

  Result = Data.define(:bytes, :content_type)

  def self.call(image_bytes:, title:)
    new(image_bytes: image_bytes, title: title).call
  end

  def initialize(image_bytes:, title:)
    @image_bytes = image_bytes
    @title       = title.to_s.strip
  end

  def call
    photo  = Vips::Image.thumbnail_buffer(@image_bytes, OG_WIDTH,
               height: OG_HEIGHT, crop: :attention, size: :both)
    photo  = photo.extract_band(0, n: 3) if photo.bands > 3

    # Replace bottom BAND_HEIGHT pixels with a solid dark band (full opacity)
    dark_band = photo.crop(0, IMAGE_HEIGHT, OG_WIDTH, BAND_HEIGHT)
                     .linear([0.0, 0.0, 0.0], BAND_COLOR)
                     .bandjoin_const([255])

    canvas = photo.composite2(dark_band, :over, x: 0, y: IMAGE_HEIGHT)
    canvas = composite_text(canvas, @title) unless @title.empty?

    Result.new(bytes: canvas.write_to_buffer(".jpg[Q=88]"), content_type: "image/jpeg")
  end

  private

  def composite_text(img, title)
    text_mask = Vips::Image.text(
      title,
      font:  FONT_SPEC,
      width: TEXT_MAX_WIDTH,
      wrap:  :word,
      dpi:   72
    )

    text_rgba = text_mask
      .new_from_image([255, 255, 255])
      .copy(interpretation: :srgb)
      .bandjoin(text_mask)

    x = ((OG_WIDTH - text_rgba.width) / 2).clamp(50, OG_WIDTH)
    # Vertically center text within the dark band
    y = IMAGE_HEIGHT + [(BAND_HEIGHT - text_rgba.height) / 2, 8].max

    img.composite2(text_rgba, :over, x: x, y: y)
  end
end
