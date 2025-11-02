require 'sidekiq/web'



Rails.application.routes.draw do
  resources :products
  post '/cart', to: 'carts#create'
  post '/cart/add_item', to: 'carts#add_item'
  get 'cart', to:  'carts#show'
  post 'cart', to: 'carts#add_product'
end
