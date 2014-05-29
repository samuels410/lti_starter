class AddNameToFeatureSets < ActiveRecord::Migration
  def change
    add_column :feature_sets, :name, :string
  end
end
