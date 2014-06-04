class SubscriptionPlansController < ApplicationController
  include SubscriptionPlansHelper
  before_filter :check_admin_user,:except => [:plans,:subscribe]


  def plans
    @org = Organization.find((params[:organization_id] ||= session['organization_id']))
    session['organization_id'] = @org.id
    @plans = @org.subscription_plans
    get_subscription
  end

  def subscribe
    @subscription_plan = SubscriptionPlan.find(params[:id])
    @subscription = Subscription.find(params[:subscription_id])
    if @subscription_plan.paid?
      redirect_to payment_confirm_path(@subscription,subscription_plan_id: @subscription_plan.id)
    else
      @subscription.update_attributes!(subscription_plan_id: @subscription_plan.id)
      if @subscription.valid?
        update_lms_account(@subscription)
        flash[:info] = "Your Plan has been changed"
        redirect_to plans_path
      end
    end
  end

  def pre_index
    @organizations = Organization.all
    if params['/subscription_plans'].present? and params['/subscription_plans']['organization_id'].present?
    redirect_to subscription_plans_path(organization_id: params['/subscription_plans']['organization_id'])
    end
  end

  def index
    @subscription_plan = SubscriptionPlan.new
    @org = Organization.find(params[:organization_id])
    @subscription_plans = @org.subscription_plans
    @feature_sets = @org.feature_sets
  end

  def create
    @subscription_plan = SubscriptionPlan.new(params[:subscription_plan])
    if @subscription_plan.save
      flash[:notice] = "Successfully created SubscriptionPlan."
      redirect_to subscription_plans_path
    else
      @subscription_plans = SubscriptionPlan.all
      render :action => 'index'
    end
  end

  def edit
    @subscription_plan = SubscriptionPlan.find(params[:id])
    @org = Organization.find((params[:organization_id] ||= session['organization_id']))
    @feature_sets =@org.feature_sets
  end

  def update
    @subscription_plan = SubscriptionPlan.find(params[:id])
    if @subscription_plan.update_attributes(params[:subscription_plan])
      flash[:notice] = "Successfully updated SubscriptionPlan."
      redirect_to subscription_plans_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    @subscription_plan = SubscriptionPlan.find(params[:id])
    @subscription_plan.destroy
    flash[:notice] = "Successfully destroyed SubscriptionPlan."
    redirect_to subscription_plans_path
  end


end
