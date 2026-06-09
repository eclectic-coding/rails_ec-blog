DASHBOARD_ADMIN_CONSTRAINT = ->(request) do
  session_id = request.cookie_jar.signed[:session_id]
  session_id && ::Session.find_by(id: session_id)&.user&.admin?
end

namespace :dashboard, path: "admin", constraints: DASHBOARD_ADMIN_CONSTRAINT do
  resources :articles
  resources :tags
  resources :users
  resources :projects
  resources :sessions, only: [:destroy]
  root to: "dashboard#index"
end