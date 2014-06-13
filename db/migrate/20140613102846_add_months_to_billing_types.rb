class AddMonthsToBillingTypes < ActiveRecord::Migration
  def change
    add_column :billing_types, :months, :integer
  end
end
