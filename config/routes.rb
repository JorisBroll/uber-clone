Rails.application.routes.draw do
  
  root 'application#login'

  namespace :admin do
    get '/home', to: 'static_pages#home'
    get '/logout_partner', to: 'static_pages#logout_partner'
    get '/map', to: 'static_pages#map'
    get '/config', to: 'static_pages#config'
    get '/logs', to: 'static_pages#logs'
    get '/operator_steps', to: 'static_pages#operator_steps'
    get '/monthly', to: 'static_pages#monthly'
    get '/monthly/pdf', to: 'static_pages#monthly_pdf'
    get '/global_stats', to: 'static_pages#global_stats'
    resources :users
    resources :partners
    resources :cars
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

  match '/ajax/:action', controller: 'ajax_functions', via: 'get'
  match '/ajax/notifications', to: 'ajax_functions#notifications', via: 'get'

end