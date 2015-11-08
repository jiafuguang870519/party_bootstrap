#coding: utf-8
module Fdn::EnterpriseDomain::History
  # To change this template use File | Settings | File Templates.
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do

    end
  end

  module ClassMethods

  end

  def compare_base(str1, ent_his_id)
    @ent_latest = Fdn::EnterpriseHistory.find ent_his_id
    #@ppr = Prs::PropertyRight.find latest_ppr_id
    str = str1
    if self.id != @ent_latest.ent_id
      str = false
    end
    if self.legal != @ent_latest.legal
      str = false
    end
    if self.ent_code != @ent_latest.ent_code
      str = false
    end
    if self.ent_level_code != @ent_latest.ent_level_code
      str = false
    end
    if self.is_reg != @ent_latest.is_reg
      str = false
    end
    if self.currency_code != @ent_latest.currency_code
      str = false
    end
    if self.reg_amt != @ent_latest.reg_amt
      str = false
    end
    if self.ent_type_code != @ent_latest.ent_type_code
      str = false
    end
    if self.operate_status_code != @ent_latest.operate_status_code
      str = false
    end
    #if self.settlement_date != @ent_latest.settlement_date
    #  str = false
    #end
    if self.ent_org_type_code != @ent_latest.ent_org_type_code
      str = false
    end
    if self.ent_region_code != @ent_latest.ent_region_code
      str = false
    end
    if self.postal_code != @ent_latest.postal_code
      str = false
    end
    if self.reg_date != @ent_latest.reg_date
      str = false
    end
    if self.is_foreign != @ent_latest.is_foreign
      str = false
    end
    if self.is_outside_to_inside != @ent_latest.is_outside_to_inside
      str = false
    end
    if self.is_gov_inv_main_ind != @ent_latest.is_gov_inv_main_ind
      str = false
    end
    if self.main_inv_org_id != @ent_latest.main_inv_org_id
      str = false
    end
    if self.purpose != @ent_latest.purpose
    end
    if self.purpose_to != @ent_latest.purpose_to
      str = false
    end
    if self.exchange_rate != @ent_latest.exchange_rate
      str = false
    end
    if self.foreign_currency != @ent_latest.foreign_currency
      str = false
    end
    if self.industries.size != 0 && @ent_latest.industries.size != 0 && self.industries.size == @ent_latest.industries.size
      self.industries.each do |e_in|
        @ent_latest.industries.each do |p_in|
          if p_in.seq == e_in.seq
            if p_in.industry_id != e_in.industry_id
              str = false
            end
          end
        end
      end
    elsif self.industries.size != @ent_latest.industries.size
      str = false
    end
    if self.fdn_ent_individuals.size != 0 && @ent_latest.fdn_ent_individuals.size != 0 && self.fdn_ent_individuals.size == @ent_latest.fdn_ent_individuals.size
      self.fdn_ent_individuals.each do |e_ind|
        @ent_latest.fdn_ent_individuals.each do |p_ind|
          if p_ind.last_id == e_ind.last_id
            if p_ind.individual_name != e_ind.individual_name
              str = false
            end
            if p_ind.actual_investor != e_ind.actual_investor
              str = false
            end
          end
        end
      end
    elsif self.fdn_ent_individuals.size != @ent_latest.fdn_ent_individuals.size
      str = false
    end
    return str
  end

  def compare
    @ent_latest = Fdn::EnterpriseHistory.where("ent_id =?", self.id).order("start_time DESC").first
    #@ppr = Prs::PropertyRight.find self.latest_ppr_id
    str = true
    if self.main_inv_org_id != @ent_latest.main_inv_org_id
      str = false
    end
    str = self.compare_base(str, @ent_latest.id)
    str = self.compare_inv(str, @ent_latest.id)
    return str
  end

  def compare_inv(str1, ent_his_id)
    @ent_latest = Fdn::EnterpriseHistory.find ent_his_id
    #@ppr = Prs::PropertyRight.find latest_ppr_id
    str = str1
    if self.investors.size != 0 && @ent_latest.investors.size != 0 && self.investors.size == @ent_latest.investors.size
      self.investors.each do |e_inv|
        @ent_latest.investors.each do |p_inv|
          if p_inv.last_id == e_inv.last_id
            if p_inv.investor_type_code != e_inv.investor_type_code
              str = false
            end
            if p_inv.org_id != e_inv.org_id
              str = false
            end
            if p_inv.investor_name != e_inv.investor_name
              str = false
            end
            if p_inv.region_code != e_inv.region_code
              str = false
            end
            if p_inv.org_type_code != e_inv.org_type_code
              str = false
            end
            if p_inv.industry_code != e_inv.industry_code
              str = false
            end
            if p_inv.amount != e_inv.amount
              str = false
            end
            if p_inv.percentage != e_inv.percentage
              str = false
            end
            if p_inv.actual_amt != e_inv.actual_amt
              str = false
            end
            if p_inv.foreign_currency != e_inv.foreign_currency
              str = false
            end
            if p_inv.actual_amt_foreign != e_inv.actual_amt_foreign
              str = false
            end
            if p_inv.capital_contribution != e_inv.capital_contribution
              str = false
            end
            if p_inv.capital_contribution_foreign != e_inv.capital_contribution_foreign
              str = false
            end
          end
        end
      end
    elsif self.investors.size != @ent_latest.investors.size
      str = false
    end
    return str
  end

  #比较本次记录和ppr的column字段
  def compare_column(column)
    #prs_property_right_last = Prs::PropertyRight.find self.latest_ppr_id
    @ent_latest = Fdn::EnterpriseHistory.where("ent_id =? and end_time != '2999-12-31 23:59:59'", self.id).order("start_time DESC").first
    if @ent_latest != nil
      if self.send(column) == @ent_latest.send(column)
        return 'true'
      else
        return 'false'
      end
    end
  end

  def history
    result = self.compare
    if result == false
      if self.latest_ppr_id.blank?
        self.ppr_status_code = '4'
      else
        self.ppr_status_code = '6'
      end
      self.start_time = Time.now
      self.save
      @ent_his_latest = Fdn::EnterpriseHistory.where("ent_id = ?", self.id).order("start_time DESC").first
      if @ent_his_latest != nil
        time = Time.now.to_i
        @ent_his_latest.end_time = Time.at(time-1)
        #@ent_his_latest.end_time = Time.now - 1
        @ent_his_latest.save
      end
      @org_his_latest = Fdn::OrganizationHistory.where("resource_type = 'Fdn::EnterpriseHistory' and resource_id = ? " ,@ent_his_latest.id).first
      if @org_his_latest != nil
        @org_his_latest.end_time = @ent_his_latest.end_time
        @org_his_latest.save
      end

      @ent_his = Fdn::EnterpriseHistory.new
      @ent_his.copy_data(self)
    else
      self.ppr_status_code = '1'
      self.save
    end
  end

  def update_history
    @ent_his_latest = Fdn::EnterpriseHistory.where("ent_id = ?", self.id).order("start_time DESC").first
    if @ent_his_latest.nil?
      @ent_his_latest = Fdn::EnterpriseHistory.new
    end
    @ent_his_latest.copy_data(self)
  end

  #比较本次记录和ppr的子类pro_right_results字段
  #def compare_result_column(i)
  #  prs_property_right_last = Prs::PropertyRight.find self.latest_ppr_id
  #  if prs_property_right_last != nil
  #    pro = self.pro_right_results[i]
  #    pro_last = prs_property_right_last.pro_right_results[i]
  #    if pro.ent_declare_value == pro_last.ent_declare_value
  #      return 'true'
  #    else
  #      return 'false'
  #    end
  #  end
  #end
end