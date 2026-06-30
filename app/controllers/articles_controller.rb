class ArticlesController < ApplicationController
  before_action :set_visible_article, only: %i[show]

  allow_unauthenticated_access only: %i[index show]

  def index
    resume_session
    @pagy, @articles = pagy(Article.includes(:tags).with_rich_text_content.with_attached_image.visible_to(current_user))

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
    set_meta_tags(ArticleMetaTags.new(@article, self).to_h)
  end

  def set_visible_article
    resume_session
    @article = Article.visible_to(current_user).friendly.find(params.require(:id))
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to root_path, alert: "Article not found." }
      format.json { head :not_found }
    end
  end
end
