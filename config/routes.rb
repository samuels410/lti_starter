Subscription::Application.routes.draw do

  resources :user_configs
  resources :external_configs
  resources :organizations
  resources :domains
  resources :feature_sets

  devise_for :users

  get "home/index"
  get "query/index"
  get "refund/index"
  root :to => "home#welcome" #make a controller, home page

  get "response/response_display"
  get "charging/charging_display"
  post "charging/charging_display"
  get "charging/show"
  post "response/response_display"
  post "query/index"
  get "query/show"
  get "refund/show"
  post "refund/index"
  post "/placement_launch",to: "lti#placement_launch"
  get "/oauth_success",to: "lti#oauth_success"
  get "/session_fix",to: "lti#session_fixed"
  get "plans",to: "feature_sets#plans"


end
