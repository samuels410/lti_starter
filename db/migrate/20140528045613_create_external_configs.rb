class CreateExternalConfigs < ActiveRecord::Migration
  def change
    create_table :external_configs do |t|
      t.string :config_type
      t.string :app_name
      t.integer :organization_id
      t.text :value
      t.text :shared_secret
      t.timestamps
    end
  end
end
