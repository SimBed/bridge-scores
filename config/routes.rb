Rails.application.routes.draw do
  resources :leagues
  resources :matches
  resources :players
  root 'matches#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
