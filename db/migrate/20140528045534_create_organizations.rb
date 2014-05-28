class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :host
      t.string :name
      t.text :url
      t.string :description
      t.string :image
      t.string :email
      t.timestamps
    end
  end
end
