class CreateUserConfigs < ActiveRecord::Migration
  def change
    create_table :user_configs do |t|
      t.integer :user_id
      t.text :access_token
      t.integer :domain_id
      t.string :name
      t.text :image
      t.string :global_user_id
      t.timestamps
    end
  end
end
