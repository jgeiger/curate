Curate::Application.routes.draw do

  devise_for :users
  resources :users, :only => [:show]

  resources :ontology_terms, :documents, :annotation_jobs

  resources :ontologies do
    collection do
      get :refresh
    end
  end

  resources :annotations do
    collection do
      get :audit
      post :mass_curate
    end

    member do
      post :predicate
      post :curate
    end
  end

  match '/help', :to => 'pages#help', :as => 'help'

  root :to => 'pages#home'
end
