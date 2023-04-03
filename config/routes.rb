# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :telegram do
    resources :webhooks, only: %i[create]
  end
end
