class ArticlesController < ApplicationController
  before_action :set_article, only: %i[ edit update destroy ]
  before_action :set_visible_article, only: %i[ show ]

  allow_unauthenticated_access only: %i[index show new create edit update destroy]

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
    @article = Article.new(article_params)

    respond_to do |format|
      if @article.save
        format.html { redirect_to @article, notice: "Article was successfully created." }
        format.json { render :show, status: :created, location: @article }
      else
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
    params.require(:article).permit(:title, :content, :published_at, :is_published, :user_id)
  end
end
