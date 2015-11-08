class CreateFdnPartyOrgs < ActiveRecord::Migration
  def change
    create_table :fdn_party_orgs do |t|
      t.string :name
      t.string :parent_name
      t.date :setting_date
      t.integer :party_members
      t.integer :pre_party_members
      t.integer :activist_party_members

      t.timestamps null: false
    end
  end
end
