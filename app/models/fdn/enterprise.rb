#coding: utf-8
module Fdn
  class Enterprise < ActiveRecord::Base
    #acts_as_flex_attr

    include Fdn::EnterpriseDomain::Util
    include Fdn::EnterpriseDomain::Biz
    include Fdn::EnterpriseDomain::History
    include Fdn::EnterpriseDomain::Report
    include Fdn::EnterpriseDomain::SyncWithPpr
    include Fdn::EnterpriseDomain::Validator

    ###
    #ATTRIBUTE
    attr_accessor :province, :city, :ent_industry_value ,:cq_parent_name,:kb_parent_name,:ys_parent_name,:js_parent_name,:nb_parent_name

    ###
    #ASSOCIATION

    has_and_belongs_to_many :users, join_table:'users_enterprises'

    has_and_belongs_to_many :important_issues_trackings, :class_name => 'Rad::ImportantIssuesTracking', join_table:'trackings_enterprises'

    #财务月报
    has_many :financial_statements, :class_name => 'Aae::FinancialStatement' ,:foreign_key => 'ent_id', :dependent => :destroy

    has_many :prs_listed_company_enterprises, :class_name => 'Prs::ListedCompanyEnterprise'
    has_one :prs_listed_companies, :class_name => 'Prs::ListedCompany' ,:foreign_key => 'ent_id'
    has_many :prs_state_owned_shares, :class_name => 'Prs::StateOwnedShare',:foreign_key => 'ent_id'

    has_one :organization, :as => :resource, :dependent => :destroy
    accepts_nested_attributes_for :organization, :allow_destroy => true

    has_many :file_resources, :class_name => 'Fdn::FileResource', :as => :resource, :dependent => :destroy
    accepts_nested_attributes_for :file_resources, :allow_destroy => true

    belongs_to :ppr_status, :class_name => 'Fdn::Lookups::PprStatus', :foreign_key => 'ppr_status_code', :primary_key => 'code'
    belongs_to :operate_status, :class_name => 'Fdn::Lookups::EntOperateStatus', :foreign_key => 'operate_status_code', :primary_key => 'code'
    belongs_to :assess_type, :class_name => 'Fdn::Lookups::EntAssessType', :foreign_key => 'ent_assess_type', :primary_key => 'code'

    belongs_to :report_type, :class_name => 'Fdn::Lookups::EntReportType', :foreign_key => 'ent_report_type', :primary_key => 'code'

    #belongs_to :statistics, :class_name => 'Fdn::Lookups::EntStatistics', :foreign_key => 'statistics_code', :primary_key => 'code'
    #belongs_to :scale, :class_name => 'Fdn::Lookups::BusinessScale', :foreign_key => 'scale_code', :primary_key => 'code'
    has_many :industries, :class_name => 'Fdn::EnterprisesIndustry', :foreign_key => 'ent_id', :dependent => :destroy
    has_many :investors, :class_name => 'Fdn::EntInvestor', :foreign_key => 'ent_id'
    accepts_nested_attributes_for :investors, :allow_destroy => true, :reject_if => proc { |attrs| (attrs['amount'].blank? && attrs['foreign_currency'].blank?) }
    has_many :results, :class_name => 'Fdn::EntResult', :foreign_key => 'ent_id'
    accepts_nested_attributes_for :results

    has_many :ent_histories, :class_name => 'Fdn::EnterpriseHistory', :foreign_key => 'ent_id', :dependent => :destroy
    accepts_nested_attributes_for :ent_histories

    has_and_belongs_to_many :contacts, :class_name => 'Prs::Contact', :join_table => 'prs_contacts_ents',
                            :foreign_key => 'ent_id', :association_foreign_key => 'contact_id'
    #个人代持股
    has_many :fdn_ent_individuals, :class_name => 'Fdn::EntIndividual', :foreign_key => "ent_id"
    accepts_nested_attributes_for :fdn_ent_individuals, :allow_destroy => true, :reject_if => proc { |attr| attr[:individual_name].blank? }

    delegate :name, :to => :organization

    ########
    #质押
    has_many :equity_mortgages, :class_name => 'Prs::EquityMortgage', :foreign_key => 'ent_id'

    ###
    #SCOPE
    scope :like_org_name, lambda { |name| includes(:organization).where('fdn_organizations.name like ?', '%'+name+'%') }

    #####
    #ent history
    scope :has_history, -> { where('fdn_enterprise_histories.end_time != \'2999-12-31 23:59:59\'') }
    scope :order_history, proc {|is_asc| order("fdn_enterprise_histories.end_time #{is_asc ? '' : 'desc'}")}

    scope :invested_at, proc {|org_id, time|
      includes(:investors).where('fdn_ent_investors.org_id = ?
                                  and ifnull(fdn_enterprises.start_time, fdn_enterprises.created_at) <= ?',
                                  org_id, time)}
    scope :by_ids, proc { |ids| where('fdn_enterprises.id in (?)', ids.split(',')) }
    scope :by_id, proc { |id| where('fdn_enterprises.id in (?)', id) }
    #scope :be_supervised, where('fdn_enterprises.parent_group_code=\'2000\'')
    scope :by_level, lambda { |level_code| where('fdn_enterprises.ent_level_code = ?', level_code) }
    scope :by_status, proc {|status| where('fdn_enterprises.ppr_status_code = ?', status)}
    scope :by_sasac_dept_id, proc {|sasac_dept_id| where('fdn_enterprises.sasac_dept_id = ?', sasac_dept_id)}

    ##############validate
    #validate :inv_code_validate
    #
    #def inv_code_validate
    #  if investors.size > 0
    #    state_count = 0
    #    control_count = 0
    #    investors.each do |i|
    #      state_count += i.percentage if Prs::PropertyRight::STATE_INV_CODE.include?(i.org_type_code)
    #      control_count += i.percentage if Prs::PropertyRight::CONTROL_INV_CODE.include?(i.org_type_code)
    #    end
    #
    #    case ent_type_code
    #      when Prs::PropertyRight::STATE_ENT_CODE
    #        if state_count < 100
    #          errors.add(:base, "国有企业->国有出资股份应等于100%！")
    #        end
    #      when Prs::PropertyRight::CONTROL_ENT_CODE
    #        if state_count == 100 || control_count <= 50
    #          errors.add(:base, "国有绝对控股企业->国有出资股份之和应大于50%！")
    #        end
    #      when Prs::PropertyRight::ACTUAL_HOLD_ENT_CODE
    #        if control_count > 50 || control_count == 0
    #          errors.add(:base, "国有实际控制企业->国有出资股份之和应大于0%且小于等于50%！")
    #        end
    #      when Prs::PropertyRight::SHARE_ENT_CODE
    #        if control_count > 50 || control_count == 0
    #          errors.add(:base, "国有参股企业->国有出资股份之和应大于0%且小于等于50%！")
    #        end
    #    end
    #  end
    #end



    #创建产权登记结果
    def build_result
      templates = Prs::RowTemplates::ProRightResultRowTemplate.find_all_by_status 'Y', :order => 'seq'
      templates.each do |template|
        self.results.build(:row_template_id => template.id)
      end
    end

    def ent_industry_value
      self.industries.map { |i| i.industry.value }.join(',')
    end

    #after_update :g_ind
    before_save :sync_code

    def sync_code
      self.organization.code = self.ent_code
    end

    def g_ind
      #p '###########################'
      unless self.ent_industry_code.blank?
        ids = self.ent_industry_code.split(',')
        self.industries.clear
        ids.each do |i|
          self.industries.create(:ent_id => self.id, :industry_id => i, :seq => ids.index(i)+1)
        end
      end
      #p self.industries
      #p '##########################'
    end

    #企业修改时自动带出是否境外转投境内
    def get_out_in_value
      if self.main_inv_org.is_ent?
        if self.main_inv_org.resource.is_foreign == 1 && self.is_foreign != 1
          self.is_outside_to_inside = 1
        else
          self.is_outside_to_inside = 0
        end
      else
        self.is_outside_to_inside = 0
      end
    end

    ################################企业查询导出用字段###########################################
    def percentage
      self.investors.size > 0 ? (self.investors.first.percentage.blank? ? '0.00%' : self.investors.first.percentage.to_s + '%') : ''
    end

    def org_type
      self.organization.org_type_name
    end

    def ent_type_value
      self.ent_type.value if self.ent_type
    end


    ###########################################################################################
    #主管部门，返回org对象
    def root(hierarchy_id=nil, time=Time.now)
      self.organization.with_hierarchy(hierarchy_id, time)
      self.organization.ent_supervisor
    end

    #主管部门，返回ent对象
    def ent_root(hierarchy_id=nil, time=Time.now)
      self.organization.with_hierarchy(hierarchy_id, time)
      self.organization.ent_supervisor.resource
    end

    #主要出资人，返回org对象
    def parent(hierarchy_id=nil, time=Time.now)
      self.organization.with_hierarchy(hierarchy_id, time)
      self.organization.nearest_parent_org
    end

    #主要出资人企业，返回ent对象，可能为空
    def ent_parent(hierarchy_id=nil, time=Time.now)
      self.organization.with_hierarchy(hierarchy_id, time)
      self.organization.nearest_parent_ent.resource if self.organization.nearest_parent_ent
    end

    ###########################
    #股权质押
    def eff_mortgage_shares
      eff_mortgages = equity_mortgages.reject {|em| em.status == 'abt' || em.impawn_month.month.ago > (em.submit_time||Time.now)}
      eff_mortgages.sum {|em| em.mortgage_quantity}
    end

    def self.more_search(current_user, params={}, page=nil, limit=nil)
      r = where(current_user.curr_org_descendants_sql('fdn_enterprises', 'id'))

      if page
        r = r.paginate(:page => page)
      elsif limit
        r = r.limit(limit)
      end
      r
    end

    def self.with_histories(page=nil, asc=false)
      r = includes(:ent_histories).has_history.order_history(asc)
      if page
        r = r.paginate(page: page)
      end
      r
    end

  end

end
# == Schema Information
#
# Table name: fdn_enterprises
#
#  id                  :integer(4)      not null, primary key
#  ent_code            :string(255)
#  status              :string(255)
#  start_date          :date
#  end_date            :date
#  legal               :string(255)
#  ent_level_code      :string(255)
#  parent_group_code   :string(255)
#  currency_code       :string(255)
#  reg_amt             :decimal(20, 2)
#  address             :string(100)
#  postal_code         :string(255)
#  latest_ppr_id       :integer(4)
#  ppr_status_code     :string(10)
#  ent_type_code       :string(255)
#  operate_status_code :string(255)
#  statistics_code     :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  created_by          :integer(4)
#  updated_by          :integer(4)
#

