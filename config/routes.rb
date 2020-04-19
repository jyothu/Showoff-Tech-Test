Rails.application.routes.draw do
  resources :users do
  	collection do
  	  get :me
  	end
  end

  resources :widgets
  resources :sessions

  root 'widgets#index'
end
