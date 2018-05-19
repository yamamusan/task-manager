Rails.application.routes.draw do
  scope :api, module: :api do
    resources :tasks, only: [:index, :show, :create, :update, :destroy]
  end
end
