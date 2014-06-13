class PaymentsController < ApplicationController
  require 'lib/constants.rb'
  require 'lib/pz_utils.rb'
  require 'lib/config.rb'
  require 'lib/charging/charging_response.rb'
  include SubscriptionPlansHelper
  include PZ_Utils
  include ChargingResponse

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

    @charging_api_url = get_charging_api_url
   @params = {
                              :merchant_id => PZ_Config::MERCHANT_ID,
                              :merchant_transaction_id => payment.merchant_transaction_id,
                              :merchant_key_id => PZ_Config::MERCHANT_KEY_ID,
                              :buyer_email_address => payment.buyer_email_address,
                              :transaction_type => payment.transaction_type,
                              :transaction_amount => payment.transaction_amount.to_i,
                              :payment_method => payment.payment_method,
                              :currency => payment.currency,
                              :ui_mode => payment.ui_mode,
                              :hash_method => payment.hash_method,
                              :bank_name => "HDFC",
                              :hash => generate_hash({
                                                         :merchant_id => PZ_Config::MERCHANT_ID,
                                                         :merchant_transaction_id => payment.merchant_transaction_id,
                                                         :merchant_key_id => PZ_Config::MERCHANT_KEY_ID,
                                                         :buyer_email_address => payment.buyer_email_address,
                                                         :transaction_type => payment.transaction_type,
                                                         :transaction_amount => payment.transaction_amount.to_i,
                                                         :payment_method => payment.payment_method,
                                                         :currency => payment.currency,
                                                         :ui_mode => payment.ui_mode,
                                                         :hash_method => payment.hash_method,
                                                         :bank_name => "HDFC",
                                                         :callback_url => PZ_Config::CALLBACK_URL
                                                     }),
                              :callback_url => PZ_Config::CALLBACK_URL
                          }

  end

  def get_charging_api_url
    PZ_Config::API_BASE + PZ_Config::API_CHARGING + "/" + PZ_Config::API_VERSION
  end

  def destroy
    Payment.find_by_identifier!(params[:id]).unsubscribe!
    redirect_to plans_path, notice: 'Recurring Profile Canceled'
  end

  def success
    @response_params = params
    # Incoming data can also be retrieved in the following manner using response_controller.rb or else in views we can display using @response_params array.

    # To check the validity of the response, call the validate function on
    # the ChargingResponse object. It verifies the hash returned in the response.
    @calculated_hash = validate()
    payment = Payment.find_by_merchant_transaction_id(@response_params[:merchant_transaction_id])
    if  @response_params[:hash] == @calculated_hash
      if payment.nil?
        flash[:info] = "Payment not found"
        redirect_to plans_path
      else
        payment.subscription.paid_through = Date.today if payment.subscription.paid_through.nil?
        payment.subscription.update_attributes(subscription_plan_id: payment.subscription_plan_id)
        update_lms_account(payment.subscription,payment.user_config_id,payment.user_config.domain_id)
        payment.completed = true
        payment.save!
        flash[:info] = "Payment Transaction Completed & Your Plan has been changed"
        redirect_to payment.final_redirect_url
      end
    else
      flash[:info] = "Generated hash not matched"
      redirect_to payment.final_redirect_url
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
