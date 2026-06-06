module Dashboard
  class ArticlesController < Dashboard::BaseController
    before_action :set_article, only: %i[show edit update destroy]

    def index
      @pagy, @articles = pagy(Article.includes(:tags).order(Arel.sql("COALESCE(published_at, created_at) DESC")))
    end

    def show
    end

    def new
      @article = Article.new
    end

    def edit
    end

    def create
      @article = Article.new(article_params)
      @article.user = Current.user

      if @article.save
        redirect_to dashboard_article_path(@article), notice: "Article was successfully created."
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      notices = []

      if @article.update(article_params)
        notices << "Article was successfully updated."

        if params.dig(:article, :remove_image).present? && params.dig(:article, :image).blank?
          if @article.image.attached?
            @article.image.purge
            notices << "Image removed."
          else
            notices << "No image was attached to remove."
          end
        end

        redirect_to dashboard_article_path(@article), notice: notices.join(" "), status: :see_other
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @article.destroy!
      redirect_to dashboard_articles_path, notice: "Article was successfully deleted.", status: :see_other
    end

    private

    def set_article
      @article = Article.friendly.find(params.require(:id))
    end

    def article_params
      params.require(:article).permit(:title, :content, :published_at, :is_published, :image, :remove_image, tag_ids: [])
    end
  end
end
