Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }, skip: [ :registrations ]

  devise_scope :user do
    get "/users/edit", to: "users/registrations#edit", as: :edit_user_registration
    patch "/users", to: "users/registrations#update", as: :user_registration
    put "/users", to: "users/registrations#update"
  end

  root "public#index"

  get "/dashboard", to: "dashboard#index"
  get "/analytics", to: "dashboard#analytics"

  resources :dashboard, only: [] do
    collection do
      get :switch_company
    end
  end

  resource :company_settings, only: [ :show, :edit, :update ]
  resources :activities, only: [ :index ]
  resources :users, only: [ :index ]
  resources :recognitions, only: [ :index, :show, :new, :create ]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
