class CreateFdnOrganizationHistories < ActiveRecord::Migration
  def change
    create_table :fdn_organization_histories do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.string :name
      t.text :description,:limit=>1.megabytes
      t.string :code
      t.string :short_name
      t.string :org_type
      t.string :resource_type
      t.integer :resource_id
      t.integer :lock_version
      t.string :purpose_from
      t.decimal :reg_amt_foreign,:precision=>20, :scale=>6
      t.integer :gov_inv_id
      t.string :dept_name
      t.integer :dept_id
      t.integer :sasac_dept_id

      t.timestamps
      t.tracer
    end
  end
end
