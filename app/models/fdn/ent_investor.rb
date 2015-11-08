#coding: utf-8
class Fdn::EntInvestor < ActiveRecord::Base
  #validates_presence_of :org_id, :if=>Proc.new{|inv| inv.investor_type_code=='ENT'}
  #validates_presence_of :investor_name, :if=>Proc.new{|inv| inv.investor_type_code=='OTH'}

  #validate :validates_ent_attributes
  belongs_to :investor_type, :class_name => 'Prs::Lookups::InvestorType', :foreign_key => 'org_type_code', :primary_key => 'code'
  belongs_to :ent, :class_name=>'Fdn::Enterprise'
  belongs_to :org, :class_name=>'Fdn::Organization'
  belongs_to :last_investor, :class_name => 'Prs::Investor', :foreign_key => 'last_id'

  #和企业组织形式标识码多对一关系
  #belongs_to :ent_org_type, :class_name=>'Prs::EntOrgType', :foreign_key=>'org_type_code', :primary_key=>'value'
  #和企业所属区域代码多对一关系
  #belongs_to :ent_region, :class_name=>'Fdn::Region', :foreign_key=>'region_code', :primary_key=>'region_code'
  #和企业所属行业代码多对一关系
  #belongs_to :ent_industry, :class_name=>'Prs::EntIndustry', :foreign_key=>'industry_code', :primary_key=>'value'

  def investor_org_name
    if org
      org.name
    else
      investor_name
    end
  end

  def investor_org_name=(attribute)
    if org_id
      self.investor_name = nil
    else
      self.investor_name = attribute
    end
  end

  #比较本次记录和history的子类investors字段
  def compare_inv_column(column)
    @ent_latests = Fdn::EnterpriseHistory.where("ent_id =? and end_time != '2999-12-31 23:59:59' ", self.ent_id).order("start_time DESC")#.first
    if @ent_latests.size != 0
      @ent_latest = @ent_latests.first
    else
      @ent_latest = Fdn::EnterpriseHistory.where("ent_id =? and end_time = '2999-12-31 23:59:59' ", self.ent_id).first
    end
    if !@ent_latest.nil?
      inv_last = Fdn::EntInvestorHistory.where("ent_id = ? and last_id = ?",@ent_latest.id,self.last_id)
      if inv_last.size != 0
        if self.send(column) == inv_last.first.send(column)
          return 'true'
        else
          return 'false'
        end
      end
    end
  end

end
