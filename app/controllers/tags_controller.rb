class TagsController < ApplicationController
  allow_unauthenticated_access only: %i[show]

  # POST /tags
  def create
    @tag = Tag.new(tag_params)

    respond_to do |format|
      if @tag.save
        format.json { render json: { id: @tag.id, name: @tag.display_name }, status: :created }
      else
        format.json { render json: { errors: @tag.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # GET /tags/:name
  def show
    @tag = Tag.find_by_param(params[:id]) || raise(ActiveRecord::RecordNotFound)
    @pagy, @articles = pagy(@tag.articles.includes(:tags).visible_to(current_user))

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  private

  def tag_params
    params.require(:tag).permit(:name)
  end
end
