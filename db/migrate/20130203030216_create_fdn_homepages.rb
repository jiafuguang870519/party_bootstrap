class CreateFdnHomepages < ActiveRecord::Migration
  def change
    create_table :fdn_homepages do |t|
      t.integer :dashboard_id
      t.integer :organization_id
      t.integer :user_id

      t.timestamps
    end

    add_index :fdn_homepages, [:organization_id, :dashboard_id]
    add_index :fdn_homepages, [:user_id, :dashboard_id]
  end
end
