class CreateFdnOrgHieVersions < ActiveRecord::Migration
  def change
    create_table :fdn_org_hie_versions do |t|      
      t.references :org_hierarchy    #引用fdn_org_hierarchy
      t.integer :ver                      #版本号
      t.date :start_date                  #开始日期
      t.date :end_date                    #结束日期
      t.integer :current_flag             #当前标志
      t.integer :resource_id
      t.string :resource_type

      t.integer :version
      t.timestamps
      t.tracer
    end

    add_index :fdn_org_hie_versions, [:org_hierarchy_id, :current_flag], :name=>'fdn_org_hie_versions_ind1'
    add_index :fdn_org_hie_versions, [:org_hierarchy_id, :ver], :name=>'fdn_org_hie_versions_ind2'
    add_index :fdn_org_hie_versions, [:resource_id, :resource_type], :name => 'fdn_org_hie_versions_ind3'
  end
end
