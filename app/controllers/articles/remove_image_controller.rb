module Articles
  class RemoveImageController < ApplicationController
    before_action :set_article
    before_action :admin_only!, only: %i[destroy]

    # DELETE /articles/:id/remove_image
    def destroy
      if @article.image.attached?
        @article.image.purge
        flash.now[:notice] = "Image removed."
      else
        flash.now[:alert] = "No image was attached."
      end

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("article-image-area-#{@article.id}", partial: "articles/image_preview", locals: { article: @article }),
            turbo_stream.replace("notices", partial: "shared/notices")
          ]
        end
        format.html { redirect_to edit_article_path(@article), notice: (flash.now[:notice] || flash.now[:alert]) }
      end
    end

    private

    def set_article
      @article = Article.find(params.require(:id))
    end
  end
end

