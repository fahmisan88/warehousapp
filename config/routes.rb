Rails.application.routes.draw do

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'landing#index'
  get '/dashboard' => 'dashboards#index'
  get '/statement' => 'shipments#statement'

  get '/register' => 'users#new'
  get '/login' => 'sessions#new'

  get '/password' => 'password#index'
  get '/password/resetpass' => 'password#resetpass'
  post '/password/forgot' => 'password#forgot'
  get '/password/reset/:token' => 'password#reset'
  post '/password/update' => 'password#update'

  post '/checkemail' => 'users#emailcheck'
  post '/checkpackage' => 'users#packagecheck'

  get '/parcels/parcel_new' => 'parcels#admin_create_parcel_show'
  post '/parcels/admin_create' => 'parcels#admin_create'
  post '/eziid_check' => 'parcels#checkezicode'

  # create new users with free registration. eligable for special agent. need key in special password to create new users
  get '/special' => 'specialusers#index'
  post '/special/new' => 'specialusers#new'
  post '/special/register' => 'specialusers#register'

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
    get :edit_awb
    get :show_image
    get :request_refund
    patch :update_awb
    put :update_awb
    patch :update_refund
    put :update_refund
    patch :update_request_refund
    put :update_request_refund
  end
  end
  resources :shipments do
    member do
      patch :calculate
      put :calculate
      patch :sea_calculate
      put :sea_calculate
      patch :add_charge
      put :add_charge
      get :add_tracking
      patch :update_tracking
      get :edit_status
      patch :update_status
    end
  end
  resources :currencies, only: [:edit, :update]
  resources :activities, only:[:index]

  scope '/webhooks', controller: :webhooks do
  post :payment_callback
  post :user_payment_callback
  end
end
