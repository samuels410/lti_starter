class Payment < ActiveRecord::Base

  attr_accessible :subscription_plan_id,:subscription_id,:user_config_id,:merchant_transaction_id,
                  :buyer_email_address,:transaction_type,:transaction_amount,:payment_method,:currency,:ui_mode,
                  :hash_method,:completed, :canceled,:final_redirect_url,:bank_name,:billing_type_id

  validates_presence_of :subscription_plan_id,:subscription_id,:user_config_id,
                          :buyer_email_address,:transaction_type,:transaction_amount,:payment_method,:currency,:ui_mode,
                          :hash_method,:final_redirect_url,:bank_name
  validates_uniqueness_of :merchant_transaction_id, uniqueness: true

  scope :completed,     where(completed: true)

  belongs_to :subscription
  belongs_to  :user_config
  belongs_to :subscription_plan
  belongs_to :billing_type


  before_create :generate_merchant_transaction_id



  def details
    if recurring?
      client.subscription(self.identifier)
    else
      client.details(self.token)
    end
  end

  attr_reader :redirect_uri, :popup_uri
  def setup!(return_url, cancel_url)
    response = client.setup(
        payment_request,
        return_url,
        cancel_url,
        pay_on_paypal: true,
        no_shipping: self.digital?
    )
    self.token = response.token
    self.save!
    @redirect_uri = response.redirect_uri
    @popup_uri = response.popup_uri
    self
  end

  def cancel!
    self.canceled = true
    self.save!
    self
  end

  def complete!(payer_id = nil)
    if self.recurring?
      response = client.subscribe!(self.token, recurring_request)
      self.identifier = response.recurring.identifier
    else
      response = client.checkout!(self.token, payer_id, payment_request)
      self.payer_id = payer_id
      self.identifier = response.payment_info.first.transaction_id
    end
    self.completed = true
    self.save!
    self
  end

  def unsubscribe!
    client.renew!(self.identifier, :Cancel)
    self.cancel!
  end

  protected

  def generate_merchant_transaction_id
    self.merchant_transaction_id = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless Payment.exists?(merchant_transaction_id: random_token)
    end
  end


  private

  def client
    Paypal::Express::Request.new PAYPAL_CONFIG
  end

  DESCRIPTION = {
      item: 'PayPal Express Sample Item',
      instant: 'PayPal Express Instant Payment',
      recurring: 'PayPal Express Sample Recurring Payment'
  }

  def payment_request
    request_attributes = if self.recurring?
                           {
                               billing_type: :RecurringPayments,
                               billing_agreement_description: DESCRIPTION[:recurring]
                           }
                         else
                           item = {
                               name: title,
                               description: description,
                               amount: self.amount
                           }
                           item[:category] = :Digital if self.digital?
                           {
                               amount: self.amount,
                               description: description,
                               items: [item]
                           }
                         end
    Paypal::Payment::Request.new request_attributes
  end

  def recurring_request
    Paypal::Payment::Recurring.new(
        start_date: Time.now,
        description: DESCRIPTION[:recurring],
        billing: {
            period: :Month,
            frequency: 1,
            amount: self.amount
        }
    )
  end

end
