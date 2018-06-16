# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index'
  scope :api, module: :api do
    resources :tasks, only: %i[index show create update destroy]
  end
  get '*path', to: 'home#index'
end
