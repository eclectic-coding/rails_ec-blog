Rails.application.routes.draw do
  draw :dashboard
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  resources :articles do
    collection do
      get :image_library, to: 'articles/image_library#index'
    end
    member do
      delete :remove_image, to: 'articles/remove_image#destroy'
    end
  end
  resources :tags, only: [:show, :create]
  resource :session

  root to: 'static#home'
  get "static/home"

  get "up" => "rails/health#show", as: :rails_health_check

  if Rails.env.test?
    get "test/sign_in/:user_id", to: "test_sign_in#create", as: "test_sign_in"
  end
end
