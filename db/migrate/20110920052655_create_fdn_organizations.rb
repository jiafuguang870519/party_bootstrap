class CreateFdnOrganizations < ActiveRecord::Migration
  def change
    create_table :fdn_organizations do |t|
      t.string :name                #组织名称     
      t.string :description         #描述
      t.string :code                #组织代码
      t.string :short_name          #简称
      t.string :org_type            #组织类型
      
      #resource
      t.string :resource_type
      t.integer :resource_id

      
      t.integer :version
      t.datetime :start_time
      t.timestamps
      t.tracer
    end

    add_index :fdn_organizations, :code
    add_index :fdn_organizations, [:resource_type, :resource_id], :name=>'fdn_organizations_ind1'
    add_index :fdn_organizations, :org_type
  end
end
