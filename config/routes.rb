Rails.application.routes.draw do
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
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  if Rails.env.development? then
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
