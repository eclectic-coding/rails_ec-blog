class ArticlesController < ApplicationController
  before_action :set_visible_article, only: %i[show]

  allow_unauthenticated_access only: %i[index show]

  def index
    resume_session
    @pagy, @articles = pagy(Article.includes(:tags).visible_to(current_user))

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    respond_to do |format|
      format.html
      format.md { render markdown: @article }
    end
  end

  private

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
