Rails.application.routes.draw do

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'landing#index'
  get '/dashboard' => 'dashboards#index'
  get '/statement' => 'shipments#statement'
  get '/register' => 'users#new'
  post '/checkemail' => 'users#emailcheck'
  resources :sessions, only: [:new, :create, :destroy]
  resources :users do
    member do
      get :pay
      patch :billplz
      put :billplz
    end
  end
  resources :parcels do
    member do
    patch :update_awb
    put :update_awb
    get :edit_awb
    get :show_image
  end
  end
  resources :shipments do
    member do
      patch :calculate
      put :calculate
    end
  end
  resources :currencies, only: [:edit, :update]
  resources :activities, only:[:index]

  scope '/webhooks', controller: :webhooks do
  post 'payment-callback', to: 'webhooks#payment_callback', as: :payment_callback
end
end
