#coding:utf-8
module Fdn
  class Organization < ActiveRecord::Base
    liquid_methods :name
    #acts_as_textile :description
    #acts_as_flex_attr
    attr_accessor :parent_dept_name, :parent_dept_id

    HIERARCHY_TREE_PARAMS = [[1,'cq_parent_id'],[2,'kb_parent_id'],[3,'ys_parent_id'],[4,'nb_parent_id'],[5,'js_parent_id'],[6,'dzz_parent_id']]

    ENTERPRISE_TYPE = 'Fdn::Enterprise'
    DEPT_TYPE = 'Fdn::Dept'

    ########################
    #domain
    include Fdn::OrganizationDomain::Biz
    include Fdn::OrganizationDomain::Util
    include Fdn::OrganizationDomain::Validator
    include Fdn::OrganizationDomain::Tree
    include Fdn::OrganizationDomain::MxGraphTree

    ########################
    #association
    has_one :homepage
    belongs_to :resource, :polymorphic => true
    belongs_to :enterprise, :foreign_key => 'resource_id'
    #has_and_belongs_to_many :old_codes
    #has_and_belongs_to_many :jobs, :class_name => 'Oa::Job'
    #has_many :hr_assignments, :class_name => "Hr::Assignment"
    has_many :users, :class_name => 'Fdn::User', :as => :resource
    has_many :roles, :class_name => 'Fdn::Role', :foreign_key => 'organization_id'
    #has_many :people, :class_name => "Hr::Person", :through => :hr_assignments
    belongs_to :org_type_obj, :class_name => 'Fdn::Lookups::OrgType',
               :foreign_key => 'resource_type', :primary_key => 'code'
    has_many :invested, -> { order 'fdn_ent_investors.percentage desc, fdn_ent_investors.amount desc' }, :class_name => 'Fdn::EntInvestor', :foreign_key => 'org_id'

    has_many :dashboards do
      def actived
        where('fdn_dashboards.active = 1')
      end
    end
    accepts_nested_attributes_for :dashboards

    delegate :sasac_dept_id, :ent_level_value, :ent_level_code, :dept_id_name, :is_outside_to_inside_value, :is_outside_to_inside,
             :ent_region_name, :ent_region_code, :main_inv_org_name, :gov_inv_name, :sasac_dept_name, :dept_short_name,
             :ent_industry_value, :industry_names, :industry_codes, :main_ind_name, :dept_name, :sasac_dept_short_name,
             :to => :enterprise, :allow_nil => true

    #############################
    #common scope
    scope :by_code, proc { |code| where('code=?', code) }
    scope :in_codes, lambda { |codes| where('code in (?)', codes) }
    scope :exclude_codes, lambda { |codes| where('code not in (?)', codes) }

    scope :select_dept, -> { where('resource_type = \'Fdn::Dept\'') }
    scope :select_ent, -> { joins(:enterprise) }
    scope :search_dept, -> { joins('inner join fdn_depts on fdn_depts.id = fdn_organizations.resource_id and fdn_organizations.resource_type = \'Fdn::Dept\'') }
    scope :gzw, -> { where('fdn_depts.type_code = \'GZW\'')}
    scope :other, -> { where('fdn_depts.type_code = \'GOV\'') }

    scope :by_id, proc { |id| where('id=?', id) }
    scope :include_ids, lambda { |org_ids| where('fdn_organizations.id in (?)', org_ids) }
    #scope :primary_org, lambda { |user_id| joins('inner join hr_assignments on fdn_organizations.id = hr_assignments.organization_id
    #  inner join hr_people on hr_people.id = hr_assignments.person_id inner join fdn_users on fdn_users.person_id = hr_people.id ').where('hr_assignments.end_date is null and hr_assignments.primary_flag=1 and fdn_users.id=?', user_id) }

    scope :by_name, proc { |name| where('name=?', name) }
    scope :like_name, proc { |name| where('name like ?', "%#{name}%") }

    scope :by_resource_id, proc { |resource_id| where("resource_type = 'Fdn::Enterprise' and resource_id=?", resource_id) }

    scope :one_level, -> { where("fdn_enterprises.ent_level_code = 1") }
    scope :two_level, -> { where("fdn_enterprises.ent_level_code = 2") }
    scope :three_level, -> { where("fdn_enterprises.ent_level_code = 3") }
    scope :four_level, -> { where("fdn_enterprises.ent_level_code >= 4") }

    #TODO cl lx
    #查询某个区域下的一级企业的数目
    scope :one_level_join, -> { joins("inner join prs_property_rights on fdn_organizations.resource_id = prs_property_rights.ent_id") }
    #TODO cl lx
    #根据企业编码查询一级企业
    scope :by_region, lambda { |registration_code| one_level_join.where("prs_property_rights.resource_type = 'Prs::OcpProRight' and prs_property_rights.ent_level_code = 1 and fdn_organizations.resource_type='Fdn::Enterprise' and prs_property_rights.status = 'app' and substring(prs_property_rights.registration_code,1,6)= ?", registration_code) }
    #TODO cl lx
    #查询境内外和几级企业
    scope :level_and_foreign, lambda { |ent_level| one_level_join.where("prs_property_rights.resource_type = 'Prs::OcpProRight' and prs_property_rights.ent_level_code = ? and prs_property_rights.is_foreign = 0 and prs_property_rights.status = 'app'", ent_level) }
    #TODO cl lx
    scope :one_level_count, lambda { |dept_id| one_level_join.where("prs_property_rights.resource_type = 'Prs::OcpProRight' and prs_property_rights.ent_level_code = 1 and prs_property_rights.status = 'app' and fdn_organizations.resource_type ='Fdn::Enterprise' and prs_property_rights.dept_id= ?", dept_id) }
    scope :in_id, lambda { |id| where('id in (?)', id) }
    before_save :bs
    after_create :ac
    #after_update :au

    def ac

    (self.resource.gov_inv_id = self.id) && self.resource.save if self.is_ent? && self.resource.gov_inv_id.blank?

    #self.resource.update_column('gov_inv_id', self.id)
    create_default_user
    create_default_role
    #if resource_type == 'Fdn::Dept' && resource.type_code == 'GZW'
    #  create_audit_standard
    #end
    #Wf::Role.create(:resource => self, :name => "ORG.#{self.code}", :status => 'Y')
    #create_default_dashboard
    end

    #def au
    #  #users.each do |u|
    #  #  r = Wf::Role.find_by_resource_id_and_resource_type self.id, self.class.name
    #  #  if r
    #  #    if r.fdn_users.detect { |us| us.id == u.id }.blank?
    #  #      Wf::User.create(:user_id => u.id, :role_id => r.id, :status => 'Y')
    #  #    end
    #  #  else
    #  #    r = Wf::Role.create(:resource => self, :name => "ORG.#{self.code}", :status => 'Y')
    #  #    Wf::User.create(:user_id => u.id, :role_id => r.id, :status => 'Y')
    #  #  end
    #  #end
    #end

    def bs
      if self.resource_type == 'Fdn::Enterprise'
        self.code = self.resource.ent_code
      end
    end

    ##多用户所在部门
    #def self.peoples_dept_org(people_ids)
    #  Fdn::Organization.joins(:people).where("hr_people.id in (?)", people_ids).select("distinct fdn_organizations.*")
    #end

    #================================================================================================
    #trigger
    def create_default_user
      #logger.info("before create user")
      self.users.create(FactoryGirl.attributes_for(:admin_user)).create_user_information(FactoryGirl.attributes_for(:admin_user_info))
      self.users.create(FactoryGirl.attributes_for(:adv_user)).create_user_information(FactoryGirl.attributes_for(:adv_user_info))
      self.users.create(FactoryGirl.attributes_for(:fdn_user, :init_pass)).create_user_information(FactoryGirl.attributes_for(:user_info))
    end

    def create_default_role
      #logger.info("before create role")
      admin_user = Fdn::User.by_org_id(self.id).like_user_name('admin').first
      ghost_user = Fdn::User.by_org_id(self.id).like_user_name('ghost').first
      adv_user = Fdn::User.by_org_id(self.id).like_user_name('manager').first
      user = Fdn::User.by_org_id(self.id).like_user_name('user').first

      #if self.id.to_s == Fdn::Profile.get_value('TOP_SASAC')
      #  menus = Fdn::Menu::ALL_ADMIN_MENUS
      #  adv_menus = Fdn::Menu::BASE_MANAGER_MENUS + Fdn::Menu::BASE_EXCLUDE_MENUS
      #  user_menus = Fdn::Menu::ALL_ADMIN_MENUS + Fdn::Menu::BASE_EXCLUDE_MENUS
      #elsif self.org_type_code == 'GZW'
      #  adv_menus = Fdn::Menu::BASE_MANAGER_MENUS + Fdn::Menu::ADV_MANAGER_MENUS
      #  menus = Fdn::Menu::BASE_ADMIN_MENUS# + Fdn::Menu::ADV_ADMIN_MENUS
      #  user_menus = Fdn::Menu::ALL_ADMIN_MENUS + Fdn::Menu::BASE_EXCLUDE_MENUS
      #elsif self.org_type_code == 'ENT' && self.resource.ent_level_code == '1'
      #  adv_menus = Fdn::Menu::BASE_MANAGER_MENUS
      #  menus = Fdn::Menu::BASE_ADMIN_MENUS# + Fdn::Menu::ADV_ADMIN_MENUS
      #  user_menus = Fdn::Menu::ALL_ADMIN_MENUS + Fdn::Menu::BASE_EXCLUDE_MENUS + Fdn::Menu::ADV_EXCLUDE_MENUS
      #else
      #  menus = Fdn::Menu::BASE_ADMIN_MENUS
      #  adv_menus = Fdn::Menu::BASE_MANAGER_MENUS
      #  user_menus = Fdn::Menu::ALL_ADMIN_MENUS + Fdn::Menu::BASE_EXCLUDE_MENUS + Fdn::Menu::ADV_EXCLUDE_MENUS# + Fdn::Menu::ENT_EXCLUDE_MENUS
      #end
      #if self.org_type_code == 'VIR'
        all_rights = Fdn::Right.all#in_menu_codes(Fdn::Menu::KB_ADMIN_MENUS)
        #adv_rights = Fdn::Right.all#in_menu_codes(Fdn::Menu::KB_OTHER_MENUS)
        #base_rights = Fdn::Right.all#in_menu_codes(Fdn::Menu::KB_OTHER_MENUS)
      #else
      #  all_rights = Fdn::Right.in_menu_codes(menus)
      #  adv_rights = Fdn::Right.in_menu_codes(adv_menus)
      #  base_rights = Fdn::Right.not_in_menu_codes(user_menus)
      #end

      Fdn::Role.init_role_with_org_and_user(self, admin_user, Fdn::Role::DEFAULT_ADMIN_ROLES, all_rights)
      Fdn::Role.init_role_with_org_and_user(self, adv_user, Fdn::Role::DEFAULT_ADV_ROLES, all_rights)
      Fdn::Role.init_role_with_org_and_user(self, user, Fdn::Role::DEFAULT_USER_ROLES, all_rights)
      #if self.id.to_s == Fdn::Profile.get_value('TOP_SASAC') || self.org_type_code == 'GZW'
      #  Fdn::Role.init_role_with_org_and_user(self, ghost_user, Fdn::Role::DEFAULT_ADMIN_ROLES, all_rights)
      #else
      #  fzgh_rights = Fdn::Right.in_menu_codes(Fdn::Menu::FZGH_MENUS)
      #  Fdn::Role.init_role_with_org_and_user(self, user, Fdn::Role::DEFAULT_FZGH_ROLES, fzgh_rights)
      #  cqgl_rights = Fdn::Right.in_menu_codes(Fdn::Menu::CQGL_MENUS)
      #  Fdn::Role.init_role_with_org_and_user(self, user, Fdn::Role::DEFAULT_CQGL_ROLES, cqgl_rights)
      #  yjkh_rights = Fdn::Right.in_menu_codes(Fdn::Menu::YJKH_MENUS)
      #  Fdn::Role.init_role_with_org_and_user(self, user, Fdn::Role::DEFAULT_YJKH_ROLES, yjkh_rights)
      #  jyys_rights = Fdn::Right.in_menu_codes(Fdn::Menu::JYYS_MENUS)
      #  Fdn::Role.init_role_with_org_and_user(self, user, Fdn::Role::DEFAULT_JYYS_ROLES, jyys_rights)
      #  djdw_rights = Fdn::Right.in_menu_codes(Fdn::Menu::DJDW_MENUS)
      #  Fdn::Role.init_role_with_org_and_user(self, user, Fdn::Role::DEFAULT_DJDW_ROLES, djdw_rights)
      #  zzxc_rights = Fdn::Right.in_menu_codes(Fdn::Menu::ZZXC_MENUS)
      #  Fdn::Role.init_role_with_org_and_user(self, user, Fdn::Role::DEFAULT_ZZXC_ROLES, zzxc_rights)
      #  aqsc_rights = Fdn::Right.in_menu_codes(Fdn::Menu::AQSC_MENUS)
      #  Fdn::Role.init_role_with_org_and_user(self, user, Fdn::Role::DEFAULT_AQSC_ROLES, aqsc_rights)
      #end
      #logger.info("after create role")
    end

    def create_audit_standard
      #logger.info("before create std")
      gzw = Fdn::Organization.find(Fdn::Profile.get_value('TOP_SASAC'))
      if self.id != gzw.id && self.org_type_code == 'GZW'
        Prs::AuditStandard.find_all_by_organization_id(gzw.id).each do |std|
          new_std = Prs::AuditStandard.create(std.attributes.merge({:organization_id => self.id}))
          std.audit_opinions.each do |o|
            new_o = new_std.audit_opinions.create(o.attributes)
            o.audit_opinion_ratings.each do |r|
              new_r = new_o.audit_opinion_ratings.create(r.attributes)
            end
          end
        end
      end
      #logger.info("after create std")
    end

    def create_default_dashboard
      if self.org_type_code != 'ENT'
        self.create_homepage(dashboard_id: Fdn::Dashboard.find_by_code('gzw_db').id)      
      else
        self.create_homepage(dashboard_id: Fdn::Dashboard.find_by_code('gzw_db').id)
      end
    end

    #财务决算合并范围取值
    def cfa_id(cfa_year_id)
      @cfa = Aae::ConsolidatedFinancialAccount.where(ent_id: self.resource_id,cfa_year_id: cfa_year_id).first
      if !@cfa.nil?
        return @cfa.id
      else
        return ''
      end
    end

    def cfa_total_assets(cfa_year_id)
      @cfa = Aae::ConsolidatedFinancialAccount.where(ent_id: self.resource_id,cfa_year_id: cfa_year_id).first
      if !@cfa.nil?
        return @cfa.total_assets
      else
        return ''
      end
    end

    def cfa_net_assets(cfa_year_id)
      @cfa = Aae::ConsolidatedFinancialAccount.where(ent_id: self.resource_id,cfa_year_id: cfa_year_id).first
      if !@cfa.nil?
        return @cfa.net_assets
      else
        return ''
      end
    end

    def cfa_audit_report(cfa_year_id)
      @cfa = Aae::ConsolidatedFinancialAccount.where(ent_id: self.resource_id,cfa_year_id: cfa_year_id).first
      if !@cfa.nil?
        return @cfa.audit_report
      else
        return ''
      end
    end

    def cfa_status(cfa_year_id)
      @cfa = Aae::ConsolidatedFinancialAccount.where(ent_id: self.resource_id,cfa_year_id: cfa_year_id).first
      if !@cfa.nil?
        return @cfa.status
      else
        return ''
      end
    end

    def cfa_audit_requirements(cfa_year_id)
      @cfa = Aae::ConsolidatedFinancialAccount.where(ent_id: self.resource_id,cfa_year_id: cfa_year_id).first
      if !@cfa.nil?
        return @cfa.audit_requirements
      else
        return ''
      end
    end


    def key_regulatory_setting(resource_id)
      @regulatory_setting = Aae::KeyRegulatorySetting.where(ent_id: resource_id).first
      if !@regulatory_setting.nil?
        return @regulatory_setting.key_regulatory
      else
        return ''
      end
    end

    def is_listed_company?
      if self.resource_type == 'Fdn::Enterprise'
        #self.ent.prs_listed_companies
        #listed_company = Prs::ListedCompany.where("ent_id=?",self.resource_id)
        if self.enterprise.prs_listed_companies#listed_company.size != 0
          return true
        else
          return false
        end
      else
        return false
      end
    end

    def listed_company
      if self.resource_type == 'Fdn::Enterprise'
        return self.enterprise.prs_listed_companies
        #return Prs::ListedCompany.where("ent_id=?",self.resource_id).first
      end
    end
  end
end
# == Schema Information
#
# Table name: fdn_organizations
#
#  id            :integer(4)      not null, primary key
#  name          :string(255)
#  description   :string(255)
#  code          :string(255)
#  short_name    :string(255)
#  org_type      :string(255)
#  resource_type :string(255)
#  resource_id   :string(255)
#  version       :integer(4)
#  created_at    :datetime
#  updated_at    :datetime
#  created_by    :integer(4)
#  updated_by    :integer(4)
#

