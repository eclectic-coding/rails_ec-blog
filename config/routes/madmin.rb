# Below are the routes for madmin
namespace :madmin, path: "admin" do
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