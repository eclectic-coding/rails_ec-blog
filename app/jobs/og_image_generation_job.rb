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

    Turbo::StreamsChannel.broadcast_replace_to(
      "article_og_image_#{article.id}",
      target: "og-card-#{article.id}",
      partial: "dashboard/articles/og_card",
      locals: { article: article.reload }
    )
  rescue Vips::Error => e
    Rails.logger.error("[OgImageGenerationJob] article=#{article_id}: #{e.message}")
    raise
  end
end
