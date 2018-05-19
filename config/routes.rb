Rails.application.routes.draw do
  namespace :api, format: 'json' do
    resources :tasks, only: [:index, :show, :create, :update, :destroy]
  end
end
