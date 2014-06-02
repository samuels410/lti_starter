module SubscriptionPlansHelper

  def get_subscription
    @subscription = Subscription.find_by_organization_id_and_subscribable_id_and_subscribable_type(@org.id,
                                                        session['account_id'],Subscription::SUBSCRIBABLE_TYPE_ACCOUNT)
    if @subscription.nil?
      subscription_plan = @org.subscription_plans.free.first
      @subscription = Subscription.create!(organization_id: @org.id,
                           subscription_plan_id: subscription_plan.id,
                           subscribable_id: session['account_id'],
                           subscribable_type: Subscription::SUBSCRIBABLE_TYPE_ACCOUNT)
    end
  end
end
