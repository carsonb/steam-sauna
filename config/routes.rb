SteamSauna::Application.routes.draw do
  get "welcome/index"
  root 'welcome#index'

  get 'login' => 'auth#index'
  post 'auth/steam/callback' => 'auth#callback'
  get '/search' => 'welcome#search'
end
