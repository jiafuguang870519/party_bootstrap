class CreateFdnOrgHieElements < ActiveRecord::Migration
  def change
    create_table :fdn_org_hie_elements do |t|
      t.references :org_hie_version     #引用fdn_org_hie_versions
      t.integer :parent_id
      t.integer :child_id
      t.integer :root_id
      t.integer :distance                   #从child到parent的距离
      t.integer :seq                    #排序
      t.datetime :start_time
      t.datetime :end_time
      t.integer :org_hierarchy_id

      t.timestamps
    end

    add_index :fdn_org_hie_elements, [:org_hie_version_id, :parent_id, :distance], :name=>'fdn_org_hie_elements_ind1'
    add_index :fdn_org_hie_elements, [:org_hie_version_id, :child_id, :distance], :name=>'fdn_org_hie_elements_ind2'
    add_index :fdn_org_hie_elements, [:org_hie_version_id, :root_id, :distance], :name=>'fdn_org_hie_elements_ind3'
    add_index :fdn_org_hie_elements, [:start_time, :end_time], :name=>'fdn_org_hie_elements_ind4'
    add_index :fdn_org_hie_elements, :start_time, :name=>'fdn_org_hie_elements_ind5'
    add_index :fdn_org_hie_elements, :end_time, :name=>'fdn_org_hie_elements_ind6'
  end
end
