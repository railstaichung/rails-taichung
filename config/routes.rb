Rails.application.routes.draw do
  #devise_for :users
  root 'landingpage#index'
  resources :events
  devise_for :users, controllers:{
    sessions: "users/sessions",
    confirmations: "users/confirmations",
    registrations: "users/registrations",
    passwords: "users/passwords",
    unlocks: "users/unlocks",
    omniauth: "users/omniauth"
  }

  if Rails.env.development? then
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
