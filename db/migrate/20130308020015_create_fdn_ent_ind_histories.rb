class CreateFdnEntIndHistories < ActiveRecord::Migration
  def change
    create_table :fdn_ent_ind_histories do |t|
      t.integer :ent_id
      t.integer :industry_id
      t.integer :seq

      t.timestamps
    end
  end
end
