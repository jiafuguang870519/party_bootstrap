class CreateFdnOrgHierarchies < ActiveRecord::Migration
  def change
    create_table :fdn_org_hierarchies do |t|
      t.string :name
      t.string :short_name
      t.string :code
      t.integer :main_flag
      t.integer :org_id
      t.integer :version
      t.string  :icon
      t.timestamps
      t.tracer
    end

    add_index :fdn_org_hierarchies, :main_flag
    add_index :fdn_org_hierarchies, :code
    add_index :fdn_org_hierarchies, :org_id
  end
end
