class CreateFdnFileTemplates < ActiveRecord::Migration
  def change
    create_table :fdn_file_templates do |t|
      t.string :resource_type, :limit=>80  #类型
      t.string :template_class, :limit=>50  #模板分类
      t.string :template_name #模板名称
      t.string :file_name  #模板文件名称
      t.integer :seq  #文件序号
      t.string :template_type, :limit=>30  #模板类型 STD, OTH
      t.string :status, :limit=>10  #状态
      t.date :start_date  #开始日期
      t.date :end_date  #结束日期
      t.timestamps
    end

    add_index :fdn_file_templates, :resource_type
    add_index :fdn_file_templates, [:resource_type, :template_class, :template_type, :status], :name => 'fdn_file_templates_ind1'
  end
end
