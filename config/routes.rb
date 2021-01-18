Rails.application.routes.draw do
  root 'story#new'

  get 'index' => 'story#index'
  post 'story' => 'story#create'

end
