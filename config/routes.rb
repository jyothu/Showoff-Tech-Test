Rails.application.routes.draw do
  resources :widgets, only: :index do
  	collection do
  	  get :all
  	end
  end

  resources :users, only: [:index, :show] do
  	collection do
      get :me
  	  put :update_profile
  	end
  end

  resources :sessions, only: [:create, :destroy]

  get 'users/me/widgets' => 'widgets#all'
  root 'widgets#index'
end
