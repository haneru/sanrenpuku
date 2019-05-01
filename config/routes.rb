Rails.application.routes.draw do

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  #
  root 'results#index'

  resources :fields
  resources :results do
    post :result, on: :collection
  end
end
