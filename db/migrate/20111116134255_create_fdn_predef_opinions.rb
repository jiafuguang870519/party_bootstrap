class CreateFdnPredefOpinions < ActiveRecord::Migration
  def change
    create_table :fdn_predef_opinions do |t|
      t.string :type_code
      t.string :content
      t.integer :user_id

      t.timestamps
    end

    add_index :fdn_predef_opinions, [:user_id, :type_code], :name=>'fdn_predef_opinions_ind1'
  end
end
