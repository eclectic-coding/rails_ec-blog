module Dashboard
  module Articles
    class OgImagesController < Dashboard::BaseController
      before_action :set_article

      # POST /admin/articles/:article_id/og_image
      def create
        OgImageGenerationJob.perform_now(@article.id)
        @article.reload

        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              "og-card-#{@article.id}",
              partial: "dashboard/articles/og_card",
              locals: { article: @article }
            )
          end
          format.html { redirect_to dashboard_article_path(@article), notice: "OG card generated.", status: :see_other }
        end
      end

      private

      def set_article
        @article = Article.friendly.find(params[:article_id])
      end
    end
  end
end
