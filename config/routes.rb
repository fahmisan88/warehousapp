Rails.application.routes.draw do

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'landing#index'
  get '/dashboard' => 'dashboards#index'
  get '/statement' => 'shipments#statement'
  resources :sessions, only: [:new, :create, :destroy]
  resources :users
  resources :parcels do
    member do
    patch :update_awb
    put :update_awb
    get :edit_awb
  end
  end
  resources :shipments
  resources :currencies, only: [:edit, :update]
  resources :activities, only:[:index]

  scope '/webhooks', controller: :webhooks do
  post 'payment-callback', to: 'webhooks#payment_callback', as: :payment_callback
end
end
