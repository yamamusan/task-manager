# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index'
  scope :api, module: :api, format: 'json' do
    resources :tasks, only: %i[index show create update] do
      delete :index, on: :collection, action: :delete
    end
  end
  get '*path', to: 'home#index'
end
