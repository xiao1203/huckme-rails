Rails.application.routes.draw do
  root "home#index"

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  get "signup", to: "registrations#new"
  post "signup", to: "registrations#create"

  resources :products, only: [:index, :show] do
    get "api", to: "products#api_show", on: :member
    resources :comments, only: [:create]
  end

  resources :invoices, only: [:index, :show]

  resources :documents, only: [:index]
  get "documents/download", to: "documents#download"

  get "diagnostics", to: "diagnostics#new"
  post "diagnostics/ping", to: "diagnostics#ping"
  post "diagnostics/fetch_url", to: "diagnostics#fetch_url"

  namespace :admin do
    resources :users, only: [:index, :show, :update]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
