class StaticController < ApplicationController
  allow_unauthenticated_access

  def home
    @latest_articles = Article.published.recent.limit(3)
  end
end
