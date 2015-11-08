class CreateFdnOrgTreeChanges < ActiveRecord::Migration
  def change
    create_table :fdn_org_tree_changes do |t|
      t.integer :hierarchy_id
      t.datetime :change_time

      t.timestamps null: false
      t.tracer
    end
  end
end
