class CreateFdnRoles < ActiveRecord::Migration
  def change
    create_table :fdn_roles do |t|
      t.string :name              #角色名称
      t.string :code              #角色代码
      t.string :description       #描述
      t.integer :organization_id

      
      t.timestamps
      t.tracer
    end

    add_index :fdn_roles, :code
    add_index :fdn_roles, :organization_id
  end
end
