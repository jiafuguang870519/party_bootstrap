#coding: utf-8
module Fdn::EnterpriseDomain::SyncWithPpr
  # To change this template use File | Settings | File Templates.
  ENT_COLUMNS = %w(ent_code status legal ent_level_code parent_group_code currency_code reg_amt address postal_code latest_ppr_id ent_type_code
                   operate_status_code statistics_code main_ind_code ent_region_code reg_date is_reg is_outside_to_inside is_foreign
                  is_gov_inv_main_ind main_inv_org_id purpose exchange_rate individual purpose_to foreign_currency purpose_from gov_inv_id
                  dept_name dept_id sasac_dept_id is_direct_sup)

  INV_COLUMNS = %w(investor_type_code org_id investor_name amount percentage region_code org_type_code industry_code
foreign_currency capital_contribution capital_contribution_foreign)

  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do

    end
  end

  module ClassMethods
    #从占有产权登记创建企业
    def create_from_ppr(ppr)
      if ppr.resource_type == 'Prs::OcpProRight'
        ent = Fdn::Enterprise.new
        ent.copy_ppr(ppr)

        ent_his = Fdn::EnterpriseHistory.new
        ent_his.copy_data(ent)
        #IMPORTANT: 重构了树的模型
        parent_org = Fdn::Organization.find(ppr.main_inv_org_id).with_hierarchy(Fdn::OrgHierarchy.main.first.id, ppr.record_time)
        parent_org.add_child(ent.organization.id)
        #
        #
        #复制当前国家出资企业树型层次镜像
        #每做一次产权登记，则复制一次
        #parent_org = Fdn::Organization.find(ppr.main_inv_org_id).with_hierarchy
        #parent_org.add_child(ent.organization.id)
        #ent_supervisor = ent.root
        #
        #new_h = Fdn::OrgHierarchy.find_or_create_by_org_id(ent_supervisor.id)
        #new_h.copy_from_latest(false)
        #new_h.curr_ver(true).resource = ppr
        #new_h.curr_ver.save
        #Fdn::Organization.find(ent_supervisor.id).with_hierarchy(new_h.id, new_h.curr_ver.ver).add_as_root
        #Fdn::Organization.dump_between_hie(Fdn::OrgHierarchy.main.first.curr_ver, new_h.curr_ver, ent_supervisor.id)

        ent
      end
    end
  end



  #从产权登记修改企业信息
  def update_from_ppr(ppr)
    if ppr.ent_id == self.id
      self.copy_ppr(ppr)

      ent_his_latest = Fdn::EnterpriseHistory.where("ent_id =?", self.id).order("start_time DESC").first
      if ent_his_latest != nil
        ent_his_latest.end_time = Time.now
        ent_his_latest.save
      end
      ent_his = Fdn::EnterpriseHistory.new
      ent_his.copy_data(self)

      #IMPORTANT: 重构了树的模型
      self.organization.with_hierarchy(Fdn::OrgHierarchy.main.first.id, ppr.record_time).change_parent(ppr.main_inv_org_id)
      #复制当前企业树型层次镜像
      #self.organization.with_hierarchy.change_parent(ppr.main_inv_org_id)

      #new_h = Fdn::OrgHierarchy.find_or_create_by_org_id(ppr.gov_inv_id)
      #new_h.copy_from_latest(false)
      #new_h.curr_ver(true).resource = ppr
      #new_h.curr_ver.save
      #
      #Fdn::Organization.find(ppr.gov_inv_id).with_hierarchy(new_h.id, new_h.curr_ver.ver).add_as_root
      #Fdn::Organization.dump_between_hie(Fdn::OrgHierarchy.main.first.curr_ver, new_h.curr_ver, ppr.gov_inv_id)

      self
    end
  end

  def copy_ppr(ppr)
    #############################
    #COMMON COLUMNS
    ENT_COLUMNS.each do |column|
      self.send("#{column}=", ppr.send(column))
    end
    ##############################
    #SPECIAL COLUMNS
    self.operate_status_code = ppr.op_status_code
    self.start_date = Date.today if self.start_date.nil?
    self.ppr_status_code = '1'
    self.latest_ppr_id = ppr.id
    ##############################
    #ORGNIZATION
    if self.new_record?
      org_attr = {short_name: ppr.ent_name, lock_version: 0}
      self.build_organization({:code => ppr.ent_code, :name => ppr.ent_name}.merge(org_attr))
    else
      org_attr = {}
      self.organization.attributes=({:code => ppr.ent_code, :name => ppr.ent_name}.merge(org_attr))
    end


    ##############################
    #INVESTORS
    self.investors.clear
    ppr.investors.each do |inv|
      self.investors.build(inv.attributes.select { |k, v|
        INV_COLUMNS.include?(k) }.merge({:actual_amt => inv.actual_inv_amt,
                                         :actual_amt_foreign => inv.actual_inv_amt_foreign,
                                         :last_id => inv.id}))
    end
    ##############################
    #INDUSTRIES
    #copy_industries(ppr)
    ##############################
    #RESULTS
    copy_results(ppr)
    ##############################
    #INDIVIDUALS
    #ONLY FOREIGN ENT
    copy_individuals(ppr)

    save
  end

  private
  #从某个产权登记复制行业
  def copy_industries(ppr)
    self.industries(true).clear
    logger.info(self.industries.inspect)
    ppr.industries.each do |ind|
      logger.info('===============')
      logger.info self.id
      logger.info ind.industry_id
      logger.info ind.seq
      self.industries.build(industry_id: ind.industry_id, seq: ind.seq)
    end
  end

  def copy_results(ppr)
    self.results.clear
    ppr.pro_right_results.each do |result|
      self.results.build(:row_template_id => result.row_template_id, :value => result.ent_declare_value, :foreign_currency => result.foreign_currency)
    end
  end

  def copy_individuals(ppr)
    self.fdn_ent_individuals.clear
    ppr.prs_ppr_individuals.each do |ind|
      self.fdn_ent_individuals.build(:individual_name => ind.individual_name,
                                     :actual_investor => ind.actual_investor,
                                     :last_id => ind.id)
    end
  end


end