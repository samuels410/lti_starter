class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.belongs_to :subscription
      t.belongs_to :user_config
      t.belongs_to :subscription_plan
      t.integer :amount, default: 1
      t.string :token, :identifier, :payer_id
      t.boolean :recurring, :digital, :popup, :completed, :canceled, default: false
      t.timestamps
    end
  end

  def self.down
    drop_table :payments
  end
end
