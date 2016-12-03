Rails.application.routes.draw do

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'landing#index'
  get '/dashboard' => 'dashboards#index'
  resources :sessions, only: [:new, :create, :destroy]
  resources :users, only: [:new, :create, :edit, :update]
  resources :parcels
  resources :shipments
  resources :currencies, only: [:new, :create, :edit, :update]
  resources :activities, only:[:index]

  scope '/webhooks', controller: :webhooks do
  post 'payment-callback', to: 'webhooks#payment_callback', as: :payment_callback
end
end
