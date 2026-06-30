class ArticleMetaTags
  def initialize(article, context)
    @article = article
    @context = context
  end

  def to_h
    meta = {
      title:       title,
      description: description,
      og: {
        title:       title,
        description: description,
        type:        "article",
        url:         url
      },
      twitter: {
        title:       title,
        description: description
      },
      canonical:    url
    }

    meta[:og][:image]      = og_image if og_image
    meta[:twitter][:image] = og_image if og_image

    meta
  end

  private

  def title
    @article.title
  end

  def description
    @description ||= @context.helpers.article_preview(@article.content, length: 160)
  end

  def url
    @url ||= @context.article_url(@article)
  end

  def og_image
    return @og_image if defined?(@og_image)

    @og_image = if @article.og_image.attached?
      @context.rails_blob_url(@article.og_image, only_path: false)
    elsif @article.image.attached?
      @context.rails_blob_url(@article.image, only_path: false)
    end
  end
end