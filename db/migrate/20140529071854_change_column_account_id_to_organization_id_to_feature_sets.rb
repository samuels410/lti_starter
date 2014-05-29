class ChangeColumnAccountIdToOrganizationIdToFeatureSets < ActiveRecord::Migration
  def up
    rename_column :feature_sets ,:account_id , :organization_id
  end

  def down
  end
end
