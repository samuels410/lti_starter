module SubscriptionPlansHelper
  require 'oauth'
  require 'oauth/request_proxy/rack_request'
  require 'canvas-api'
  include ApplicationHelper
  
  def get_subscription
    @subscription = Subscription.find_by_organization_id_and_subscribable_id_and_subscribable_type(@org.id,
                                                        session['account_id'],Subscription::SUBSCRIBABLE_TYPE_ACCOUNT)
    if @subscription.nil?
      subscription_plan = @org.subscription_plans.free.first
      @subscription = Subscription.create!(organization_id: @org.id,
                           subscription_plan_id: subscription_plan.id,
                           subscribable_id: session['account_id'],
                           subscribable_type: Subscription::SUBSCRIBABLE_TYPE_ACCOUNT)
      if @subscription.valid?
        update_lms_account(@subscription)
      end
    end
  end

  def update_lms_account(subscription)
    user_config = UserConfig.find_by_user_id_and_domain_id(session["user_id"], session['domain_id'])
    subscription_params = {:no_students => subscription.subscription_plan.feature_set.no_students ,
                           :no_teachers => subscription.subscription_plan.feature_set.no_teachers ,
                           :no_admins => subscription.subscription_plan.feature_set.no_admins,
                           :no_courses => subscription.subscription_plan.feature_set.no_courses,
                           :storage => subscription.subscription_plan.feature_set.storage,
                           :unlimited => subscription.subscription_plan.feature_set.unlimited}
    json = api_call("/api/v1/accounts/#{subscription.subscribable_id}/subscribe",user_config,false,:post, subscription_params)

  end

end
