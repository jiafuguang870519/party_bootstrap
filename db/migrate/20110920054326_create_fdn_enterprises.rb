class CreateFdnEnterprises < ActiveRecord::Migration
  def change
    create_table :fdn_enterprises do |t|
      t.string :ent_code                                  #企业编码
      t.string :status                                    #状态
      t.date   :start_date                                #开始日期
      t.date   :end_date                                  #结束日期
      t.string :legal                                     #法定代表人
      t.string :ent_level_code                            #企业级次编码
      t.string :parent_group_code                         #上级集团标识码
      t.string :currency_code                             #币种
      t.decimal :reg_amt, :precision => 20, :scale => 2   #注册资金
      
      t.string :address, :limit => 100                    #地址
      t.string :postal_code                               #邮编
      t.string :ent_industry_code
      
      t.integer :latest_ppr_id                            #最后一次产权登记id 
                
      t.string :ppr_status_code, :limit => 10             #产权登记状态
      t.string :ent_type_code                             #企业类型
      t.string :operate_status_code                       #经营状态
      t.string :statistics_code                           #是否合并报表
      t.string :main_ind_code                             #主要行业
      t.string :ent_region_code                           #注册地区域代码
      t.date :reg_date                                    #注册日期
      t.integer :is_reg                                   #是否注册
      t.integer :is_outside_to_inside                     #是否境外转投境内
      t.integer :is_foreign                               #是否外资
      t.integer :is_gov_inv_main_ind                      #是否国家出资企业主业
      t.integer :main_inv_org_id
      t.integer :purpose
      t.decimal :exchange_rate ,:precision=>20, :scale=>2
      t.integer :individual
      t.date :purpose_to
      t.decimal :foreign_currency ,:precision=>20, :scale=>2
      t.datetime :start_time
      t.string :purpose_from
      t.decimal :reg_amt_foreign, :precision => 20, :scale => 6
      t.integer :gov_inv_id
      t.string :dept_name                                 #产权主管部门
      t.integer :dept_id                                  #产权主管部门
      t.integer :sasac_dept_id                            #国资监管部门
      t.integer :is_direct_sup                            #是否国资委直接管理
      t.timestamps
      t.tracer
    end

    add_index :fdn_enterprises, [:ent_code], :name=>'fdn_enterprises_ind1'
    add_index :fdn_enterprises, [:ent_level_code, :ent_type_code, :operate_status_code], :name=>'fdn_enterprises_ind2'
    add_index :fdn_enterprises, :main_ind_code, :name=>'fdn_enterprises_ind3'
    add_index :fdn_enterprises, :ent_region_code, :name=>'fdn_enterprises_ind4'
    add_index :fdn_enterprises, :is_foreign, :name=>'fdn_enterprises_ind5'
  end
end
