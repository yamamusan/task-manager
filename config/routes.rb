Rails.application.routes.draw do
  root to: 'home#index'
  scope :api, module: :api do
    resources :tasks, only: [:index, :show, :create, :update, :destroy]
  end
end
