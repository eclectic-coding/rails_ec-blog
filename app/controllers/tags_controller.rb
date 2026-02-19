class TagsController < ApplicationController
  allow_unauthenticated_access only: %i[index show]

  # GET /tags
  def index
    @tags = Tag.includes(:articles).ordered
  end

  # GET /tags/:id
  def show
    @tag = Tag.find(params[:id])
    @pagy, @articles = pagy(@tag.articles.visible_to(current_user))

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end

