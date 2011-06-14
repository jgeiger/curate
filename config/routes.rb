Curate::Application.routes.draw do

  devise_for :users
  resources :users, :only => [:show]

  resources :ontologies, :ontology_terms, :documents

  match '/help', :to => 'pages#help', :as => 'help'

  root :to => 'pages#home'
end
