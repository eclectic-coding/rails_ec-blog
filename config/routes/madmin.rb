# Below are the routes for madmin
ADMIN_CONSTRAINT = ->(request) do
  session_id = request.cookie_jar.signed[:session_id]
  session_id && ::Session.find_by(id: session_id)&.user&.admin?
end

namespace :madmin, path: "admin", constraints: ADMIN_CONSTRAINT do
  namespace :active_storage do
    resources :attachments
    resources :blobs
    resources :variant_records
  end
  namespace :action_text do
    resources :rich_texts
    resources :encrypted_rich_texts
  end
  resources :articles
  resources :article_tags
  resources :sessions
  resources :tags
  resources :users
  root to: "dashboard#show"
end