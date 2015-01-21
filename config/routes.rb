
TwitterExample::Application.routes.draw do

  require 'sidekiq/web'
  require 'sidekiq/api'
  require 'sidekiq-status/web'


  resources :tweets do 
    collection do
      get 'search'
      post 'remove_all_jobs'
    end
  end

  mount Sidekiq::Web => '/monitoring'
  
  #API
  namespace :api do
    namespace :v1 do
      resources :tasks do
        collection do
          match 'handler'
        end
      end
    end
  end

  resources :oauth do
    collection do
      match 'callback'
    end
  end

  root :to => "oauth#index"

end
