class OgImageService
  OG_WIDTH        = 1200
  OG_HEIGHT       = 630
  OVERLAY_OPACITY = 0.72
  TEXT_MAX_WIDTH  = 1100
  FONT_SPEC       = "DejaVu Sans Bold 52"

  Result = Data.define(:bytes, :content_type)

  def self.call(image_bytes:, title:)
    new(image_bytes: image_bytes, title: title).call
  end

  def initialize(image_bytes:, title:)
    @image_bytes = image_bytes
    @title       = title.to_s.strip
  end

  def call
    base   = Vips::Image.thumbnail_buffer(@image_bytes, OG_WIDTH,
               height: OG_HEIGHT, crop: :centre, size: :both)
    base   = base.extract_band(0, n: 3) if base.bands > 3
    canvas = apply_dark_overlay(base)
    canvas = composite_text(canvas, @title) unless @title.empty?
    Result.new(bytes: canvas.write_to_buffer(".jpg[Q=88]"), content_type: "image/jpeg")
  end

  private

  def apply_dark_overlay(img)
    band_h = (OG_HEIGHT * 0.45).round
    alpha  = (OVERLAY_OPACITY * 255).round
    y_pos  = OG_HEIGHT - band_h

    black_strip = img
      .crop(0, y_pos, OG_WIDTH, band_h)
      .linear([0.0, 0.0, 0.0], [0.0, 0.0, 0.0])
      .bandjoin_const([alpha])

    img.composite2(black_strip, :over, x: 0, y: y_pos)
  end

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

    margin = 48
    x = ((OG_WIDTH - text_rgba.width) / 2).clamp(50, OG_WIDTH)
    y = [OG_HEIGHT - text_rgba.height - margin, 10].max

    img.composite2(text_rgba, :over, x: x, y: y)
  end
end
