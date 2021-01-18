Rails.application.routes.draw do

  get 'new' => 'new#index'

  get 'stories' => 'stories#index'
end
