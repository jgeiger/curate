Curate::Application.routes.draw do

  match '/help', :to => 'pages#help', :as => 'help'

  root :to => 'pages#home'
end
