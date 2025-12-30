json.extract! article, :id, :title, :content, :published_at, :is_published, :user_id, :created_at, :updated_at
json.url article_url(article, format: :json)
