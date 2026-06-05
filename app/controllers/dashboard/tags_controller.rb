module Dashboard
  class TagsController < Dashboard::BaseController
    before_action :set_tag, only: %i[show edit update destroy]

    def index
      @pagy, @tags = pagy(Tag.ordered)
    end

    def show
    end

    def new
      @tag = Tag.new
    end

    def edit
    end

    def create
      @tag = Tag.new(tag_params)

      if @tag.save
        redirect_to dashboard_tag_path(@tag), notice: "Tag was successfully created."
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @tag.update(tag_params)
        redirect_to dashboard_tag_path(@tag), notice: "Tag was successfully updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @tag.destroy!
      redirect_to dashboard_tags_path, notice: "Tag was successfully deleted.", status: :see_other
    end

    private

    def set_tag
      @tag = Tag.find_by_param(params.require(:id))
      raise ActiveRecord::RecordNotFound unless @tag
    end

    def tag_params
      params.require(:tag).permit(:name)
    end
  end
end
