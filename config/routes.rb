Rails.application.routes.draw do
  #devise_for :users
  root 'landingpage#index'

  resources :events do
    member do
      post :join
      post :quit
    end
  end

  namespace :account do
    resources :events
    resources :my_events
  end

  devise_for :users, controllers:{
    sessions: "users/sessions",
    confirmations: "users/confirmations",
    registrations: "users/registrations",
    passwords: "users/passwords",
    unlocks: "users/unlocks",
    omniauth: "users/omniauth",
  }

  resources :users do    
    resources :profiles
  end

  if Rails.env.development? then
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
