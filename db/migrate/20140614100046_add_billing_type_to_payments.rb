class AddBillingTypeToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :billing_type_id, :integer
  end
end
