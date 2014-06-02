class CreateSubscriptionPlans < ActiveRecord::Migration
  def self.up
    create_table :subscription_plans, :force => true do |t|
      t.column :organization_id, :integer, :null => false
      t.column :name, :string, :null => false
      t.column :redemption_key, :string
      t.column :rate_cents, :integer, :null => false
      t.column :feature_set_id, :string, :null => false
    end
  end

  def self.down
    drop_table :subscription_plans
  end
end
