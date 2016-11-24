Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'landing#index'
  get '/dashboard' => 'dashboards#index'
  resources :sessions, only: [:new, :create, :destroy]
  resources :users, only: [:new, :create, :edit, :update]
  resources :parcels
  resources :shipments
end
