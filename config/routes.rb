Rails.application.routes.draw do

    resources :user_configs
    resources :external_configs
    resources :organizations
    resources :domains

    resources :enrollments do
      collection do
        get :activate_users
      end
    end

    devise_for :users

    get "home/index"
    root :to => "home#welcome" #make a controller, home page
    post "/placement_launch",to: "lti#placement_launch"
    get "/oauth_success",to: "lti#oauth_success"
    get "/session_fix",to: "lti#session_fixed"


  end
