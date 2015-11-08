class CreateFdnEntIndividualHistories < ActiveRecord::Migration
  def change
    create_table :fdn_ent_individual_histories do |t|
      t.string   :individual_name
      t.string   :actual_investor
      t.integer  :ent_id
      t.datetime :created_at,      :null => false
      t.datetime :updated_at,      :null => false
      t.integer  :last_id
    end
  end
end
