class CreateFdnMenus < ActiveRecord::Migration
  def change
    create_table :fdn_menus do |t|
      t.string :name              #菜单名称
      t.string :code              #菜单代码
      t.string :description       #描述
      t.string :title_img         #菜单前的小图标的地址
      t.string :controller        #对应控制器名称
      t.string :action            #对应动作名称
      t.string :params            #对应参数
      t.string :route_path        #对应的地址
      
      #acts_as_tree
      t.integer :parent_id        #父菜单id
      t.integer :children_count   #子菜单的数量
      t.integer :position         #排序
      t.integer :depth            #深度
      t.string :status, :limit=>1, :default => "Y" #状态


      t.timestamps
      t.tracer
    end

    add_index :fdn_menus, :code
    add_index :fdn_menus, :parent_id
    add_index :fdn_menus, :status
  end
end
