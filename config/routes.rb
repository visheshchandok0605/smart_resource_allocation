Rails.application.routes.draw do
  resources :office_resources
  resources :resource_bookings do
    member do
      patch :approve
      patch :reject
      patch :check_in
      # One-click actions from emails
      get :quick_check_in
      get :quick_cancel
    end
    collection do
      get :availability
    end
  end
  resources :users, only: [:index, :create, :show]
  get "reports/dashboard", to: "reports#dashboard"
  
  # Custom Authentication Route
  post "auth/login", to: "sessions#login"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
