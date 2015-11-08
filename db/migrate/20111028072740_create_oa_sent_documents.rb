class CreateOaSentDocuments < ActiveRecord::Migration
  def change
    create_table :oa_sent_documents do |t|
      t.string :doc_type_code      #公文类型
      t.string :secret_level_code  #密级
      t.string :doc_urgency_code   #紧急程度
      t.string :doc_word_code      #公文字
      t.integer :year              #年号
      t.integer :no                #文号
      t.string :title              #标题
      t.text :content, :limit=>2.megabytes            #正文
      t.integer :organization_id   #拟稿部门
      t.string :pri_sent_org_name  #主送部门
      t.string :cc_sent_org_name   #抄送部门
      t.string :ccr_sent_org_name  #抄报单位
      t.datetime :sign_time        #签发日期
      t.string :keyword            #主题词
      t.text :memo                 #备注
      t.integer :print_org_id      #印发单位id
      t.datetime :print_time       #印发时间
      t.integer :print_count    #印发份数
      t.integer :print_template_id #发文模板id
      t.datetime :sent_time        #办结时间
      t.string :status             #状态
      t.string :gzw_doc_level_code      #国资委公文等级
      t.integer :no_arch

      t.timestamps
      t.tracer
    end
  end
end