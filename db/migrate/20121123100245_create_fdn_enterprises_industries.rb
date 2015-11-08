class CreateFdnEnterprisesIndustries < ActiveRecord::Migration
  def change
    create_table :fdn_enterprises_industries do |t|
      t.column :ent_id, :integer
      t.column :industry_id ,:string
      t.column :seq, :integer
      t.column :last_id, :integer
    end

    add_index :fdn_enterprises_industries, [:ent_id, :industry_id, :seq], :unique => true, :name => 'fdn_enterprises_industries_ind1'
  end
end
