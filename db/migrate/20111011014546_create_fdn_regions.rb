class CreateFdnRegions < ActiveRecord::Migration
  def change
    create_table :fdn_regions do |t|
      t.string :region_code      #地区编码
      t.string :country          #国家
      t.string :province         #省
      t.string :city             #市
      t.string :district         #区
      t.integer :parent_id       #父id

      t.timestamps
    end

    add_index :fdn_regions, :region_code
    add_index :fdn_regions, :parent_id
    add_index :fdn_regions, :country
    add_index :fdn_regions, [:country, :province, :city], :name=>'fdn_regions_ind1'
  end
end
