Rails.application.routes.draw do
  
  root 'application#login'

  namespace :admin do
    get '/home', to: 'static_pages#home'
    get '/logout_partner', to: 'static_pages#logout_partner'
    get '/map', to: 'static_pages#map'
    get '/config', to: 'static_pages#config'
    get '/logs', to: 'static_pages#logs'
    get '/monthly', to: 'static_pages#monthly'
    get '/monthly/pdf', to: 'static_pages#monthly_pdf'
    resources :users
    resources :partners
    resources :promocodes
    resources :courses
    resources :companies
    resources :payments
  end

  namespace :partner_admin do
    get '/home', to: 'static_pages#home'
    get '/map', to: 'static_pages#map'
    get '/monthly', to: 'static_pages#monthly'
    get '/monthly/pdf', to: 'static_pages#monthly_pdf'
    resources :users
    resources :cars
    resources :courses
    resources :companies
  end

  resources :sessions, only: [:new, :create, :destroy]
  
  match '/login', to: 'application#login', via: 'get'
  match '/logout', to: 'sessions#destroy', via: 'delete'

  match '/ajax/get', to: 'ajax_functions#get', via: 'get'
  match '/ajax/notifications', to: 'ajax_functions#notifications', via: 'get'

end