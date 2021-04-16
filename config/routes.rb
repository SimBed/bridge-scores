Rails.application.routes.draw do
  devise_for :users
  resources :leagues
  resources :matches
  resources :players
  root 'leagues#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
