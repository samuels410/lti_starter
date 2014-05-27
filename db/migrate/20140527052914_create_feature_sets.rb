class CreateFeatureSets < ActiveRecord::Migration
  def up
    create_table :feature_sets, :force => true do |t|
      t.column :account_id, :integer, :null => false
      t.column :no_students, :integer
      t.column :no_teachers, :integer
      t.column :no_admins, :integer
      t.column :no_courses, :integer
      t.column :storage, :integer
    end
  end

  def down
    drop_table :feature_sets
  end
end
