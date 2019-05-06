Rails.application.routes.draw do
  root 'results#index'

  resources :fields
  resources :results, except: %w[index edit] do
    post :result, on: :collection
  end
  resources :racers, except: %w[edit] do
    post :collect, on: :collection
  end
end
