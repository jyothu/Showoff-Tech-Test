Rails.application.routes.draw do
  resources :widgets

  root 'widgets#index'
end
