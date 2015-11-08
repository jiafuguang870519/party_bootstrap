class CreateFdnRights < ActiveRecord::Migration
  def change
    create_table :fdn_rights do |t|
      t.string :code                  #权利代码
      t.string :type_code             #权利类型
      t.string :description           #描述
      t.string :app_code              #对应应用代码
      t.string :controller            #对应控制器
      t.string :action                #对应动作
      t.integer :menu_id         #菜单ID

      t.timestamps
    end

    add_index :fdn_rights, [:type_code, :code], :name=>'fdn_rights_ind1'
    add_index :fdn_rights, :app_code
    add_index :fdn_rights, :menu_id
  end
end
