class CreateFdnUserInformations < ActiveRecord::Migration
  def change
    create_table :fdn_user_informations do |t|
      t.string :full_name     #全名
      t.string :tel           #固定电话
      t.string :mobile        #手机
      t.string :fax           #传真
      t.string :address       #联系地址
      t.string :postal_code   #邮编
      t.string :email         #电子邮箱
      t.string :post
      t.string :im_soft
      t.text :memo
      t.references :user

      t.timestamps
      t.tracer
    end

    add_index :fdn_user_informations, [:user_id, :full_name], :name=>'fdn_user_informations_ind1'
  end
end
