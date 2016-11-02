Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root 'landingpage#index'
  resources :events do
    member do
      post :join
      post :quit
      post :to_active
      post :to_close
      get :crop
    end

    collection do
      get :active
      get :inactive
    end
  end

  resources :issues do
    member do
      post :issue_close
      post :issue_reopen
    end
    resources :issue_responds do
      post 'up_vote'
      post 'down_vote'
    end
  end

  namespace :account do
    resources :events, only: [:index]
    resources :my_events do
      member do
        post :kickout
      end
    end
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

  get 'tags/:tag', to: 'beefs#index', as: :tag
  resources :beefs
  root to: 'beefs#index'

  if Rails.env.development? then
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
    require 'sidekiq/web'
    require 'sidekiq-scheduler/web'
    mount Sidekiq::Web => '/sidekiq'    
  end
end
