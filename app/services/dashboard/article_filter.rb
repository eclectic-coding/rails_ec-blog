module Dashboard
  class ArticleFilter
    SORT_COLUMNS = %w[title date status].freeze

    attr_reader :sort, :direction, :query

    def initialize(params)
      @sort      = SORT_COLUMNS.include?(params[:sort]) ? params[:sort] : "date"
      @direction = params[:direction] == "asc" ? "asc" : "desc"
      @query     = params[:q].to_s.strip
    end

    def scope
      base = Article.includes(:tags)
      base = base.where("articles.title LIKE ?", "%#{query}%") if query.present?
      base.sorted(sort, direction)
    end
  end
end