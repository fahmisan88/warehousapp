Rails.application.routes.draw do

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'landing#index'
  get '/dashboard' => 'dashboards#index'
  get '/statement' => 'shipments#statement'
  get '/register' => 'users#new'
  post '/checkemail' => 'users#emailcheck'
  post '/checkpackage' => 'users#packagecheck'
  resources :sessions, only: [:new, :create, :destroy]
  resources :users do
    member do
      get :pay
      patch :billplz
      put :billplz
      get :edit_ewallet
      patch :update_ewallet
      put :update_ewallet
      post :suspend
      post :block
      post :activate
      get :edit_id
      patch :update_id
      put :update_id
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
      patch :add_charge
      put :add_charge
    end
  end
  resources :currencies, only: [:edit, :update]
  resources :activities, only:[:index]

  scope '/webhooks', controller: :webhooks do
  post :payment_callback
  post :user_payment_callback
  end
end
