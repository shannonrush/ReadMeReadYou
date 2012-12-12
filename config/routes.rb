ReadMeReadYou::Application.routes.draw do
  devise_for :users, :controllers => { :registrations => "registrations" }  
  resources :users 
  resources :submissions do
    resources :critiques, :only => :index
  end
  resources :critiques
  resources :comments
  resources :alerts, :only => :update
  resources :messages do
    get :autocomplete_user_first, :on => :collection
  end
  root :to => 'welcome#index'
end
