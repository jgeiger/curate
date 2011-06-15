Curate::Application.routes.draw do

  devise_for :users
  resources :users, :only => [:show]

  resources :ontology_terms, :documents

  resources :ontologies do
    collection do
      get :refresh
    end
  end

  match '/help', :to => 'pages#help', :as => 'help'

  root :to => 'pages#home'
end
