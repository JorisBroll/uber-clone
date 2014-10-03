Rails.application.routes.draw do
  
  root 'application#login'

  namespace :admin do
    get '/home', to: 'static_pages#home'
    get '/logout_partner', to: 'static_pages#logout_partner'
    resources :users
    resources :partners
    resources :promocodes
    resources :courses
  end

  namespace :partner_admin do
    get '/home', to: 'static_pages#home'
    get '/map', to: 'static_pages#map'
    resources :users
    resources :cars
    resources :courses
  end

  resources :sessions, only: [:new, :create, :destroy]
  
  match '/login', to: 'application#login', via: 'get'
  match '/logout', to: 'sessions#destroy', via: 'delete'

end
