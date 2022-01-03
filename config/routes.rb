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
    get '/companies/pdf', to: 'static_pages#companies_pdf'
    get '/global_stats', to: 'static_pages#global_stats'
    get '/partner_home', to: 'static_pages#partner_home'
    post '/email', to: 'static_pages#email'
    post '/invoice_email', to: 'static_pages#invoice_email'
    get '/download_sepa_order', to: 'static_pages#download_sepa_order'
    get '/sms', to: 'static_pages#sms'
    get '/test', to: 'static_pages#test'
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

  match '/ajax/:action', controller: 'ajax_functions', via: [:get, :post]
  match '/apps/:action', controller: 'app_calls', via: [:get, :post]
  match '/ajax/notifications', to: 'ajax_functions#notifications', via: 'get'

end