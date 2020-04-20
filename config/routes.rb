Rails.application.routes.draw do
  resources :widgets, only: [:index, :create, :destroy] do
  	collection do
  	  get :all
  	end
  end

  resources :users, only: [:index, :show, :create] do
  	collection do
      get :me
  	  put :update_profile
      post :reset_password
  	end
  end

  resources :sessions, only: [:create, :destroy]

  get 'users/me/widgets' => 'widgets#all'
  post 'users/me/change_password' => 'users#change_password'
  root 'widgets#index'
end
