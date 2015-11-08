#coding: utf-8
module Fdn::EnterpriseDomain::Util
  # To change this template use File | Settings | File Templates.
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      belongs_to :p_purpose, :class_name => 'Prs::Lookups::PropertyPurpose', :foreign_key => 'purpose', :primary_key => 'code'
      #企业类型
      belongs_to :ent_type, :class_name => 'Prs::Lookups::EntType', :foreign_key => 'ent_type_code', :primary_key => 'code'
      #和企业级次标识码多对一关系
      belongs_to :ent_level, :class_name => 'Fdn::Lookups::EntLevel', :foreign_key => 'ent_level_code', :primary_key => 'code'
      #和企业所属行业代码多对一关系
      belongs_to :main_industry, :class_name => 'Prs::Lookups::EntIndustry', :foreign_key => 'main_ind_code', :primary_key => 'code'
      #和企业所属区域代码多对一关系
      belongs_to :ent_region, :class_name => 'Fdn::Region', :foreign_key => 'ent_region_code', :primary_key => 'region_code'
      belongs_to :currency, :class_name => 'Fdn::Lookups::Currency', :foreign_key => 'currency_code', :primary_key => 'code'
      belongs_to :ent_org_type, :class_name => 'Prs::Lookups::EntOrgType', :foreign_key => 'ent_org_type_code', :primary_key => 'code'
      belongs_to :gov_inv, :class_name => 'Fdn::Organization', :foreign_key => 'gov_inv_id'
      belongs_to :main_inv_org, :class_name => 'Fdn::Organization', :foreign_key => 'main_inv_org_id'
      belongs_to :sasac_dept_obj, :class_name => 'Fdn::Organization', :foreign_key => 'sasac_dept_id'
      belongs_to :dept_obj, :class_name => 'Fdn::Organization', :foreign_key => 'dept_id'
    end
  end

  module ClassMethods

  end

  #企业级次
  def ent_level_value
    ent_level.value if self.ent_level_code
  end

  def ent_level_value=(value)
  end

  #所属部门
  def dept_id_name
    dept_obj.name if dept_id
  end

  alias_method :dept_name, :dept_id_name

  def dept_id_name=(value)
  end

  #是否境外转投境内
  def is_outside_to_inside_value
    Fdn::YES_OR_NO[self.is_outside_to_inside.to_i]
  end

  def is_outside_to_inside_value=(value)
  end

  #地区码
  def ent_region_name
    self.ent_region.region_name((self.is_foreign == 1 ? false : true)) unless self.ent_region_code.blank?
  end

  #主要出资人名称
  def main_inv_org_name
    self.main_inv_org.name if self.main_inv_org
  end

  def main_inv_org_name=(value)
  end

  #国家出资企业名称
  def gov_inv_name
     self.gov_inv ? self.gov_inv.name : self.name
  end

  def gov_inv_name=(value)
  end

  def gov_inv_ent_id
    self.gov_inv.resource_id if self.gov_inv
  end

  # 国资监管机构名称
  def sasac_dept_name
    self.sasac_dept_obj.name if self.sasac_dept_obj
  end

  def sasac_dept_name=(value)
  end

  def sasac_dept_short_name
    self.sasac_dept_obj.short_name if self.sasac_dept_obj
  end

  def dept_short_name
    self.dept_obj.short_name if self.dept_obj
  end

  def dept_name=(value)
  end

  def ent_industry_value
    self.industries.map { |i| i.industry.value }.join(',')
  end
  alias_method :industry_names, :ent_industry_value

  def industry_codes
    self.industries(true).map{|i| i.industry_id.to_s}
  end

  def industry_names=(value)
  end

  def main_ind_name
    self.main_industry.value if self.main_industry
  end
  alias_method :main_ind_value, :main_ind_name

  def main_ind_name=(value)
  end
end