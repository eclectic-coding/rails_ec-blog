module Dashboard
  class DashboardController < Dashboard::BaseController
    def index
      @article_count = Article.count
      @published_count = Article.where(is_published: true).count
      @tag_count = Tag.count
      @user_count = User.count
    end
  end
end