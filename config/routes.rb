Rails.application.routes.draw do
  root 'landingpage#index'
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
