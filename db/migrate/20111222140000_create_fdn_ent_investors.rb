class CreateFdnEntInvestors < ActiveRecord::Migration
  def change
    create_table :fdn_ent_investors do |t|
      t.integer :ent_id
      t.string :investor_type_code
      t.integer :org_id
      t.string :investor_name
      t.string :region_code
      t.string :org_type_code
      t.string :industry_code
      t.decimal :amount, :precision=>20, :scale=>2
      t.decimal :percentage, :precision=>20, :scale=>2
      t.integer :lock_version
      t.decimal :actual_amt, :precision=>10, :scale=>2
      t.integer :last_id
      t.decimal :actual_amt_foreign ,:precision=>10, :scale=>2
      t.decimal :capital_contribution ,:precision=>10, :scale=>2
      t.decimal :capital_contribution_foreign ,:precision=>10, :scale=>2
      t.decimal :foreign_currency ,:precision=>10, :scale=>2

      t.timestamps
      t.tracer
    end

    add_index :fdn_ent_investors, :ent_id
    add_index :fdn_ent_investors, :org_id
  end
end
