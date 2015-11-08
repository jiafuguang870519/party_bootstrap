class CreateFdnDepts < ActiveRecord::Migration
  def change
    create_table :fdn_depts do |t|
      t.integer :seq          #排序号
      t.integer :internal     #是否内部1/0
      t.datetime :start_time
      t.string   :type_code   #组织类型：国资委/虚拟部门/其他部门等
      t.timestamps
      t.tracer
    end

    add_index :fdn_depts, :internal
  end
end
