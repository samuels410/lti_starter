class CreateBillingTypes < ActiveRecord::Migration
  def change
    create_table :billing_types do |t|
      t.belongs_to :organization
      t.string :billing_type
      t.decimal :discount_percentage
      t.timestamps
    end
  end
end
