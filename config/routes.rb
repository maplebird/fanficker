Rails.application.routes.draw do
  root to: 'stories#new'

  get '/' => 'stories#new'
  get '/new' => 'stories#new'
  get '/index' => 'stories#index'
  get '/stories' => 'stories#index'
  get '/stories/:id' => 'stories#view'

  resources :stories
end
