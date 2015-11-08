class CreateFdnLookups < ActiveRecord::Migration
  def change
    create_table :fdn_lookups do |t|
      t.string :code          #字典代码
      t.string :type          #字典类型，保留字段
      t.string :type_name     #类型名称
      t.string :value         #值
      t.string :description   #描述
      t.string :status        #状态 Y/N
      t.date :start_date      #启用时间
      t.date :end_date        #停用时间
      t.integer :seq          #排序标识
      t.integer :parent_id    #父亲节点ID
      
      t.timestamps
      t.tracer
    end

    add_index :fdn_lookups, [:type, :status], :name=>'fdn_lookups_ind1'
    add_index :fdn_lookups, [:type, :code], :name=>'fdn_lookups_ind2'
    add_index :fdn_lookups, :parent_id, :name=>'fdn_lookups_ind3'
  end
end
