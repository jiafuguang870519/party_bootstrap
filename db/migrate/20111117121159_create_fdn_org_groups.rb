class CreateFdnOrgGroups < ActiveRecord::Migration
  def change
    create_table :fdn_org_groups do |t|
      t.string :name
      t.string :org_ids
      t.string :desc
      
      t.timestamps
      t.tracer
    end
  end
end
