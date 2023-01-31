Rails.application.routes.draw do
  devise_for :users
  resources :leagues
  resources :matches
  resources :players
  root 'leagues#index'
end
