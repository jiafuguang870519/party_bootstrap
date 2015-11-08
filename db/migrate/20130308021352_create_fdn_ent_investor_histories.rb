class CreateFdnEntInvestorHistories < ActiveRecord::Migration
  def change
    create_table :fdn_ent_investor_histories do |t|
      t.integer  :ent_id
      t.string   :investor_type_code
      t.integer  :org_id
      t.string   :investor_name
      t.string   :region_code
      t.string   :org_type_code
      t.string   :industry_code
      t.decimal  :amount,                       :precision => 20, :scale => 2
      t.decimal  :percentage,                   :precision => 20, :scale => 2
      t.integer  :lock_version
      t.datetime :created_at,                                                  :null => false
      t.datetime :updated_at,                                                  :null => false
      t.integer  :created_by
      t.integer  :updated_by
      t.decimal  :actual_amt,                   :precision => 10, :scale => 2
      t.integer  :last_id
      t.decimal  :actual_amt_foreign,           :precision => 10, :scale => 2
      t.decimal  :capital_contribution,         :precision => 10, :scale => 2
      t.decimal  :capital_contribution_foreign, :precision => 10, :scale => 2
      t.decimal  :foreign_currency,             :precision => 10, :scale => 2
      t.timestamps
    end
  end
end
