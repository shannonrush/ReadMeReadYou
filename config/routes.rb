ReadMeReadYou::Application.routes.draw do
  devise_for :users, :controllers => { :registrations => "registrations" }  
  resources :users 
  resources :submissions do
    resources :critiques, :only => :index
  end
  resources :critiques
  resources :comments
  root :to => 'welcome#index'
end
