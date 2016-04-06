Rails.application.routes.draw do

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :pull_requests, only: [] do
        post :status, on: :collection
        post :update_cache, on: :collection
      end
    end
  end
end
