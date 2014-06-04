class PaymentsController < ApplicationController
  include SubscriptionPlansHelper

  rescue_from Paypal::Exception::APIError, with: :paypal_api_error

  def payment_confirm
    @subscription = Subscription.find(params[:subscription_id])
    @subscription_plan = SubscriptionPlan.find(params[:subscription_plan_id])
    @grouped_payments = [[Payment.new]]
  end


  def show
    @payment = Payment.find_by_identifier! params[:id]
  end

  def create
    payment = Payment.create! params[:payment]
    payment.setup!(
        success_payments_url,
        cancel_payments_url,
    )
    if payment.popup?
      redirect_to payment.popup_uri
    else
      redirect_to payment.redirect_uri
    end
  end

  def destroy
    Payment.find_by_identifier!(params[:id]).unsubscribe!
    redirect_to plans_path, notice: 'Recurring Profile Canceled'
  end

  def success
    handle_callback do |payment|
      payment.complete!(params[:PayerID])
      payment.subscription.paid_through = Date.today if payment.subscription.paid_through.nil?
      payment.subscription.update_attributes(subscription_plan_id: payment.subscription_plan_id)
      update_lms_account(payment.subscription)
      flash[:info] = "Payment Transaction Completed & Your Plan has been changed"
      redirect_to plans_path
      return
    end
  end

  def cancel
    payment = Payment.find_by_token! params[:token]
    payment.cancel!
    flash[:info] = 'Payment Request Canceled'
    redirect_to plans_path
  end

  private

  def handle_callback
    payment = Payment.find_by_token! params[:token]
    @redirect_uri = yield payment
    if payment.popup?
      render :close_flow, layout: false
    end
  end

  def paypal_api_error(e)
    flash[:error] = e.response.details.collect(&:long_message).join('<br />')
    redirect_to plans_url
  end

end
