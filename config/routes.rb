Rails.application.routes.draw do

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'landing#index'
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
  post '/updatepackage' => 'users#update_package'

  post '/eziid_check' => 'parcels#checkezicode'

  # create new users with free registration. eligable for special agent. need key in special password to create new users
  get '/special' => 'specialusers#index'
  post '/special/new' => 'specialusers#new'
  post '/special/register' => 'specialusers#register'

  get '/renew' => 'users#renew'
  post '/renewalprocess' => 'users#billplz_bill_renewal'
  get '/renewalprocess' => 'users#billplz_getbill'

  get '/suspend' => 'block_suspend_users#index'

  get '/ic/upload' => 'identitycards#new'
  post '/ic/create' => 'identitycards#create'

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
      get :request_refund
      patch :update_request_refund
    end
  end
  resources :shipments do
    member do
      get :invoice
    end
  end
  resources :dashboards, only: :index
  resources :activities, only: :index

  scope '/webhooks', controller: :webhooks do
  post :payment_callback
  post :user_payment_callback
  post :renewal_callback
  end

  namespace :admin do
    resources :dashboards, only: :index
    resources :currencies, only: [:edit, :update]
    resources :parcels do
      member do
        post :accept_refund
        post :reject_refund
      end
    end
    resources :shipments, except: :index do
      member do
        patch :calculate
        patch :update_tracking
        patch :update_status
        patch :sea_calculate
        get :invoice
        get :edit_sea
      end
      collection do
        get :air
        get :sea
      end
    end
    resources :users, only: [:index, :show, :edit, :update] do
      member do
        get :edit_id
        patch :update_id
      end
    end
    resources :statements, only: :index do
      member do
        get :invoice
      end
    end
  end
end
