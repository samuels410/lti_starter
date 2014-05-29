class AddPriceToFeatureSets < ActiveRecord::Migration
  def change
    add_column :feature_sets, :price, :integer
  end
end
