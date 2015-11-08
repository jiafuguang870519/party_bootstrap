class CreateFdnDashboards < ActiveRecord::Migration
  def change
    create_table :fdn_dashboards do |t|
      t.integer :user_id
      t.integer :organization_id
      t.string :name
      t.string :code
      t.integer :active
      t.text :layout

      t.timestamps
      t.tracer
    end

    add_index :fdn_dashboards, [:user_id, :active]
    add_index :fdn_dashboards, [:organization_id, :active]
  end
end
