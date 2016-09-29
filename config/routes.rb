Rails.application.routes.draw do
  root 'landingpage#index'
<<<<<<< HEAD
=======

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

>>>>>>> e8cd9a855a555ca06381636bf9535b0f46720119
  devise_for :users, controllers:{
    sessions: "users/sessions",
    confirmations: "users/confirmations",
    registrations: "users/registrations",
    passwords: "users/passwords",
    unlocks: "users/unlocks",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  resources :events

  if Rails.env.development? then
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
