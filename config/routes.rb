Rails.application.routes.draw do
  root 'landingpage#index'
  resources :events do
    member do
      post :join
      post :quit
      post :to_active
      post :to_close
    end

    collection do
      get :active
      get :close
    end
  end

  namespace :account do
    resources :events, only: [:index]
    resources :my_events, only: [:index, :show]
  end

  devise_for :users, controllers:{
    sessions: "users/sessions",
    confirmations: "users/confirmations",
    registrations: "users/registrations",
    passwords: "users/passwords",
    unlocks: "users/unlocks",

    omniauth_callbacks: "users/omniauth_callbacks"

  }

  resources :users do
    resources :profiles
    resources :images
    member do
      get :following, :followers
    end
  end
  resources :relationships,       only: [:create, :destroy]

  if Rails.env.development? then
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
