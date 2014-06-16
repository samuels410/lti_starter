class AddBankNameToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :bank_name, :string
  end
end
