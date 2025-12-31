Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  resources :articles do
    member do
      delete :remove_image
    end
  end
  resource :session
  resources :passwords, param: :token

  root to: 'static#home'
  get "static/home"

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :admin do
    get "dashboard/show"
  end

end
