class OgImageGenerationJob < ApplicationJob
  queue_as :default

  discard_on ActiveJob::DeserializationError

  def perform(article_id)
    article = Article.find_by(id: article_id)
    return unless article&.image&.attached?

    result = OgImageService.call(
      image_bytes: article.image.download,
      title:       article.title
    )

    article.og_image.attach(
      io:           StringIO.new(result.bytes),
      filename:     "og-#{article.slug}.jpg",
      content_type: result.content_type
    )
  rescue Vips::Error => e
    Rails.logger.error("[OgImageGenerationJob] article=#{article_id}: #{e.message}")
    raise
  end
end
