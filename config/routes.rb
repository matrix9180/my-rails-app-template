Rails.application.routes.draw do
  get  "sign_in", to: "sessions#new"
  post "sign_in", to: "sessions#create"
  get  "sign_up", to: "registrations#new"
  post "sign_up", to: "registrations#create"
  resources :sessions, only: [ :show ]

  resources :profiles, only: [ :show ]
  get "profile", to: "profiles#my_profile", as: :my_profile
  get "profile/edit", to: "profiles#edit", as: :edit_my_profile
  patch "profile", to: "profiles#update", as: :update_my_profile
  put "profile", to: "profiles#update"
  patch "profile/avatar", to: "profiles#update_avatar", as: :update_my_profile_avatar
  put "profile/avatar", to: "profiles#update_avatar"
  resources :profiles, only: [ :show ]
  namespace :identity do
    resource :email,              only: [ :edit, :update ]
    resource :email_verification, only: [ :show, :create ]
    resource :password_reset,     only: [ :new, :edit, :create, :update ]
  end
  namespace :authentications do
    resources :events, only: :index
  end
  namespace :two_factor_authentication do
    namespace :challenge do
      resource :totp,           only: [ :new, :create ]
      resource :recovery_codes, only: [ :new, :create ]
    end
    namespace :profile do
      resource  :totp,           only: [ :new, :create, :update ]
    end
  end
  get  "/auth/failure",            to: "sessions/omniauth#failure"
  get  "/auth/:provider/callback", to: "sessions/omniauth#create"
  post "/auth/:provider/callback", to: "sessions/omniauth#create"
  namespace :sessions do
    resource :passwordless, only: [ :new, :edit, :create ]
    resource :sudo, only: [ :new, :create ]
  end

  # Settings pages
  get "settings", to: "settings#index", as: :settings
  namespace :settings do
    resource :profile, only: [ :show, :update ]
    resource :password, only: [ :show, :update ]
    resource :email, only: [ :show, :update ]
    resource :appearance, only: [ :show, :update ]
    resource :two_factor_authentication, only: [ :show, :create, :update ], controller: "two_factor_authentication" do
      resources :recovery_codes, only: [ :index, :create ], controller: "two_factor_authentication/recovery_codes"
    end
    resources :sessions, only: [ :index, :destroy ]
    resources :events, only: [ :index ]
  end

  # Admin pages
  namespace :admin do
    root "users#index"
    resources :users do
      resources :events, only: [ :index ], controller: "users/events"
      resources :sessions, only: [ :index, :destroy ], controller: "users/sessions" do
        collection do
          delete :destroy_all
        end
      end
      resource :avatar, only: [ :show, :destroy ], controller: "users/avatars"
    end
  end

  root "home#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check


  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
