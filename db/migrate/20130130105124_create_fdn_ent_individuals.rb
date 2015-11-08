class CreateFdnEntIndividuals < ActiveRecord::Migration
  def change
    create_table :fdn_ent_individuals do |t|
      t.string :individual_name
      t.string :actual_investor
      t.integer :ent_id

      t.timestamps
    end
  end
end
