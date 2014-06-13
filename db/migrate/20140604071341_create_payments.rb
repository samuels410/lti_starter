class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.belongs_to :subscription
      t.belongs_to :user_config
      t.belongs_to :subscription_plan
      t.text :merchant_transaction_id,:final_redirect_url
      t.decimal :transaction_amount
      t.string  :buyer_email_address, :transaction_type,:payment_method,:currency,:ui_mode,:hash_method
      t.boolean  :completed, :canceled, default: false
      t.timestamps
    end
  end

  def self.down
    drop_table :payments
  end
end
