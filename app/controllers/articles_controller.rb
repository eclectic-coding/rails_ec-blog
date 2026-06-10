class ArticlesController < ApplicationController
  before_action :set_visible_article, only: %i[show]

  allow_unauthenticated_access only: %i[index show]

  def index
    resume_session
    @pagy, @articles = pagy(Article.includes(:tags).visible_to(current_user))

    set_meta_tags(
      title:       "Articles",
      description: "Articles on Ruby on Rails, open source development, and " \
                   "software engineering by Chuck Smith.",
      og: {
        title: "Articles | Eclectic Coding",
        type:  "website",
        url:   articles_url
      },
      canonical:    articles_url
    )

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    set_article_meta_tags
    respond_to do |format|
      format.html
      format.md { render markdown: @article }
    end
  end

  private

  def set_article_meta_tags
    description = helpers.article_preview(@article.content, length: 160)
    og_image = og_image_url_for(@article)

    meta = {
      title:       @article.title,
      description: description,
      og: {
        title:       @article.title,
        description: description,
        type:        "article",
        url:         article_url(@article)
      },
      twitter: {
        title:       @article.title,
        description: description
      },
      canonical:    article_url(@article)
    }

    meta[:og][:image]      = og_image if og_image
    meta[:twitter][:image] = og_image if og_image

    set_meta_tags(meta)
  end

  def og_image_url_for(article)
    return rails_blob_url(article.og_image, only_path: false) if article.og_image.attached?

    rails_blob_url(article.image, only_path: false) if article.image.attached?
  end

  def set_visible_article
    begin
      resume_session
      @article = Article.visible_to(current_user).friendly.find(params.require(:id))
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        format.html { redirect_to root_path, alert: "Article not found." }
        format.json { head :not_found }
      end
    end
  end
end
