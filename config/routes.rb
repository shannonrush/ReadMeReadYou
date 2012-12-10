ReadMeReadYou::Application.routes.draw do
  devise_for :users, :controllers => { :registrations => "registrations" }  
  resources :users
  resources :submissions
  resources :critiques
  resources :comments
  root :to => 'welcome#index'
end
