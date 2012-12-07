ReadMeReadYou::Application.routes.draw do
  devise_for :users, :controllers => { :registrations => "registrations" }  
  resources :users
  resources :submissions
  resources :critiques
  root :to => 'welcome#index'
end
