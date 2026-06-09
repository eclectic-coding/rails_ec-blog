class StaticController < ApplicationController
  allow_unauthenticated_access

  def home
    @latest_articles = Article.published.recent.limit(5)
    @gems = Project.featured_first

    set_meta_tags(
      title:       "Chuck Smith — Senior Rails Engineer",
      description: "Senior Software Engineer passionate about Ruby on Rails, " \
                   "open source gems, and software craftsmanship.",
      og: {
        title: "Chuck Smith — Senior Rails Engineer",
        type:  "website",
        url:   root_url
      },
      canonical:    root_url
    )
  end
end
