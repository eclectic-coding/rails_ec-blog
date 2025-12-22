class ArticlesController < ApplicationController
  before_action :set_article, only: %i[ edit update destroy ]
  before_action :set_visible_article, only: %i[ show ]

  allow_unauthenticated_access only: %i[index show new create edit update destroy]

  # Protect create/edit/update/destroy for admins only (unchanged)
  before_action :admin_only!, only: %i[new create edit update destroy]

  # GET /articles or /articles.json
  def index
    resume_session
    @articles = Article.visible_to(current_user)
  end

  # GET /articles/1 or /articles/1.json
  def show
  end

  # GET /articles/new
  def new
    @article = Article.new
  end

  # GET /articles/1/edit
  def edit
  end

  # POST /articles or /articles.json
  def create
    resume_session

    @article = Article.new(article_params)
    if respond_to?(:current_user) && current_user.present?
      @article.user_id = current_user.id
    elsif params.dig(:article, :user_id).present?
      @article.user_id = params[:article][:user_id].to_i
    else
      @article.user_id = User.first&.id
    end

    respond_to do |format|
      if @article.save
        format.html { redirect_to @article, notice: "Article was successfully created." }
        format.json { render :show, status: :created, location: @article }
      else
        # Log minimal error for server-side troubleshooting
        Rails.logger.debug "Article save failed: #{ @article.errors.full_messages.join(', ') }"
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /articles/1 or /articles/1.json
  def update
    respond_to do |format|
      if @article.update(article_params)
        format.html { redirect_to @article, notice: "Article was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @article }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1 or /articles/1.json
  def destroy
    @article.destroy!

    respond_to do |format|
      format.html { redirect_to articles_path, notice: "Article was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_article
    @article = Article.find(params.require(:id))
  end

  def set_visible_article
    begin
      resume_session
      @article = Article.visible_to(current_user).find(params.require(:id))
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        format.html { redirect_to root_path, alert: "Article not found." }
        format.json { head :not_found }
      end
    end
  end

  # Only allow a list of trusted parameters through.
  def article_params
    resume_session

    permitted = [:title, :content, :published_at, :is_published]

    params.require(:article).permit(permitted)
  end
end
