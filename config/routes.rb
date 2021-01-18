Rails.application.routes.draw do
  resources :chapter_data
  root to: 'stories#new'

  get '/' => 'stories#new'
  get '/new' => 'stories#new'
  get '/index' => 'stories#index'
  get '/stories/:id' => 'stories#view'

  resources :stories
end
