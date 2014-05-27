Subscription::Application.routes.draw do

  devise_for :users

  get "home/index"
  get "query/index"
  get "refund/index"
  root :to => "home#index" #make a controller, home page

  get "response/response_display"
  get "charging/charging_display"
  post "charging/charging_display"
  get "charging/show"
  post "response/response_display"
  post "query/index"
  get "query/show"
  get "refund/show"
  post "refund/index"

end
