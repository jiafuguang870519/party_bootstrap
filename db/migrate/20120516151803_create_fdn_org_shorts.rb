class CreateFdnOrgShorts < ActiveRecord::Migration
  def change
    create_table :fdn_org_shorts do |t|
      t.string :name
      t.integer :organization_id
      t.integer :act_dept_id
      t.timestamps
      t.tracer
    end

    add_index :fdn_org_shorts, [:organization_id, :act_dept_id], :name => 'fdn_org_shorts_ind1'
  end
end
