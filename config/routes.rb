Curate::Application.routes.draw do

  devise_for :users

  resources :users, :only => [:show]

  resources :ontologies

  match '/help', :to => 'pages#help', :as => 'help'

  root :to => 'pages#home'
end
