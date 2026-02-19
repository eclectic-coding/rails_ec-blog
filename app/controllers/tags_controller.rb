class TagsController < ApplicationController
  allow_unauthenticated_access only: %i[show]

  # GET /tags/:name
  def show
    @tag = Tag.find_by_param(params[:id]) || raise(ActiveRecord::RecordNotFound)
    @pagy, @articles = pagy(@tag.articles.visible_to(current_user))

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
