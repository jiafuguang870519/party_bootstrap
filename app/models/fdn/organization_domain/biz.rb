#coding: utf-8
module Fdn::OrganizationDomain::Biz
  # To change this template use File | Settings | File Templates.
  ENTERPRISE_TYPE = 'Fdn::Enterprise'
  DEPT_TYPE = 'Fdn::Dept'
  #公司制企业
  COMP_TYPE_CODE = ["11", "12", "13", "14", "15", "16"]
  #上市公司
  IPO_TYPE_CODE = ["14"]
  #文化产业
  CULTURE_CODE = ["2410", "2411", "2412", "2413", "2414", "2419", "4151", "4152", "4153", "4154",
                  "4155", "4159", "6541", "6542", "6543", "6544", "6545", "6546", "6547", "6548",
                  "6549", "7320", "7321", "7329", "8820", "8821", "8822", "8823", "8824", "8825",
                  "8829", "8900", "8910", "8920", "8930", "8931", "8932", "8940", "9010", "9020",
                  "9030", "9040"]

  # INV_TYPE = ["国有资本", "外商资本", "民间资本"]
  INV_TYPE = ["国有资本", "其他资本"]

  #国有资本
  STATE_AMT = ["000", "001", "002", "003"]
  #其他资本
  OTHER_AMT = "004"

  # #外商资本
  # FORE_AMT = "004"
  # #民间资本
  # FOLK_AMT = "005"


  def self.included(base)
    base.extend(ClassMethods)

    base.class_eval do
      include Fdn::OrganizationDomain::Biz::InstanceMethods
    end
  end

  module ClassMethods
    #搜索子节点
    def search(org_id, query_params=nil)
      if query_params.blank? || (query_params && query_params[:org_id].blank?)
        o = find(org_id).with_hierarchy.children
      else
        o = by_id(query_params[:org_id]).with_hierarchy.children
      end
      #unless query_params[:date].blank?
      #  o = o.by_date(query_params['date'])
      #end
    end

    #自己和自己的所有父子节点
    def self_group(org_id)
      org = Fdn::Organization.find(org_id)
      org.with_hierarchy
      (org.all_descendants + org.ancestors + [org])
    end
  end

  module InstanceMethods

    ###################决策分析####################
    #取所有下属公司制企业
    def get_comp_type(hierarchy_id=nil, time=Time.now)
      self.with_hierarchy(hierarchy_id, time).all_descendants.keep_if { |x| (Fdn::Organization::COMP_TYPE_CODE.include?(x.resource.ent_org_type_code.to_s)) if x.is_ent? }
    end

    #取所有下属上市企业
    def get_ipo_type(hierarchy_id=nil, time=Time.now)
      self.with_hierarchy(hierarchy_id, time).all_descendants.keep_if { |x| (Fdn::Organization::IPO_TYPE_CODE.include?(x.resource.ent_org_type_code.to_s)) if x.is_ent? }
    end

    #文化产业
    def get_culture_type(hierarchy_id=nil, time=Time.now)
      # self.with_hierarchy(hierarchy_id, time).all_descendants.keep_if { |x| (Fdn::Organization::CULTURE_CODE.include?(x.resource.main_ind_code.to_s)) if x.is_ent? }
      self.with_hierarchy(hierarchy_id, time).all_descendants.keep_if { |x| (Fdn::Organization::CULTURE_CODE & x.resource.industries.map(&:industry).map(&:code).map(&:to_s)).present?}
    end

    #取国有资本 actual_inv_amt
    def get_state_type
      arr = self.is_ent? ? self.resource.investors.to_a.keep_if { |x| STATE_AMT.include?(x.org_type_code.to_s) } : []
      count = 0
      arr.each { |x| count += x.actual_amt }
      count
    end

    # #取外商资本
    # def get_fore_type
    #   arr = self.is_ent? ? self.resource.investors.all.keep_if { |x| FORE_AMT==x.org_type_code.to_s } : []
    #   count = 0
    #   arr.each { |x| count += x.actual_amt }
    #   count
    # end
    #
    # #取民间资本
    # def get_folk_type
    #   arr = self.is_ent? ? self.resource.investors.all.keep_if { |x| FOLK_AMT==x.org_type_code.to_s } : []
    #   count = 0
    #   arr.each { |x| count += x.actual_amt }
    #   count
    # end

    #取其他资本
    def get_other_type
      arr = self.is_ent? ? self.resource.investors.to_a.keep_if { |x| OTHER_AMT==x.org_type_code.to_s } : []
      count = 0
      arr.each { |x| count += x.actual_amt }
      count
    end

    ################################################

    #国家出资企业，向上找
    def ent_supervisor
      self.with_hierarchy unless self.hierarchy_id && self.eff_time
      ans = self.ancestors
      p 'ans'
      if ans.blank? || ans.empty?
        if self.resource_type == ENTERPRISE_TYPE
          self
        end
      else
        if self.resource_type == ENTERPRISE_TYPE
          ans.detect { |a| a.resource_type == ENTERPRISE_TYPE && a.resource.ent_level_code == '1' } || self
        end

      end

      end

    #国家出资企业，向下找
    def ent_supervisors
      self.with_hierarchy unless self.hierarchy_id && self.eff_time
      if self.resource_type == DEPT_TYPE
        self.children.select { |o| o.resource_type == ENTERPRISE_TYPE && o.resource.ent_level_code == '1' }
      else
        []
      end
    end

    #当前组织所属国资监管部门
    def curr_sasac
      self.with_hierarchy unless self.hierarchy_id && self.eff_time
      if self.resource_type == DEPT_TYPE && self.resource.type_code == 'GZW'
        return self
      end
      ans = self.ancestors
      #logger.info(ans.inspect)
      if ans.blank? || ans.empty?
        self
      else
        ans.detect { |a| a.resource_type != ENTERPRISE_TYPE && a.resource.type_code == 'GZW' }
      end

    end

    #当前组织所属政府部门
    def curr_gov_dept
      self.with_hierarchy unless self.hierarchy_id && self.eff_time
      if self.resource_type == DEPT_TYPE && (self.resource.type_code == 'GZW' || self.resource.type_code == 'GOV')
        return self
      end
      ans = self.ancestors
      if ans.blank? || ans.empty?
        self
      else
        ans.detect { |a| a.resource_type == DEPT_TYPE && (a.resource.type_code == 'GOV' || a.resource.type_code == 'GZW') }
      end
    end

    #最接近的上级企业
    def nearest_parent_ent
      self.with_hierarchy unless self.hierarchy_id && self.eff_time
      ans = self.ancestors
      if ans.blank? || ans.empty?
        nil
      else
        ans.detect { |a| a.resource_type == ENTERPRISE_TYPE }
      end
    end

    #最接近的上级组织，非VIR
    def nearest_parent_org
      self.with_hierarchy unless self.hierarchy_id && self.eff_time
      ans = self.ancestors
      if ans.blank? || ans.empty?
        nil
      else
        ans.detect { |a| a.resource_type == ENTERPRISE_TYPE || a.resource_type == DEPT_TYPE && a.resource.type_code != 'VIR' }
      end
    end

    #当前国资监管机构列表，如果有下级国资监管机构一并列出
    def curr_sasac_collection
      self.with_hierarchy unless self.hierarchy_id && self.eff_time
      if self.resource_type == DEPT_TYPE && self.resource.type_code == 'GZW'

        result = [self]
        low_level_sasac = self.all_descendants.select { |o| o.resource_type == DEPT_TYPE && o.resource.type_code == 'GZW' }
        result << low_level_sasac unless low_level_sasac.empty?
        result.flatten
      else
        [curr_sasac]
      end
    end

    ########
    #截止某个时间投资的企业
    #返回 [
    #       {
    #         ent:
    #         time:
    #         amt:
    #         percentage:
    #       }
    #     ]
    def invested_at(time)
      #inv_pprs = Prs::PropertyRight.invested_at(self.id, time)
      inv_ents = Fdn::Enterprise.invested_at(self.id, time)
      inv_ents_his = Fdn::EnterpriseHistory.invested_at(self.id, time)


      new_inv_ents = inv_ents.map { |ent| inv = ent.investors.detect { |inv| inv.org_id == self.id }
      {ent: ent,
       time: ent.start_time||ent.created_at,
       amt: inv.actual_amt,
       percentage: inv.percentage}
      }

      new_inv_ents_his = inv_ents_his.map { |ent| inv = ent.investors.detect { |inv| inv.org_id == self.id }
      {ent: ent.ent,
       time: ent.start_time||ent.created_at,
       amt: inv.actual_amt,
       percentage: inv.percentage}
      }

      new_inv_ents.empty? ? new_inv_ents_his : new_inv_ents
    end

    def be_invested_at(time)
      if self.is_ent?
        if self.resource.start_time||self.resource.created_at >= time
          self.resource.investors.map { |inv|
            {
                id: inv.org_id,
                name: inv.investor_org_name,
                type: inv.org_type_code,
                percentage: inv.percentage,
                amt: inv.actual_amt
            }
          }
        else
          Fdn::EnterpriseHistory.by_ent_id(self.resource_id).by_start_time(time).by_end_time(time).first.investors.map { |inv|
            {
                id: inv.org_id,
                name: inv.investor_org_name,
                type: inv.org_type_code,
                percentage: inv.percentage,
                amt: inv.actual_amt
            }
          }
        end
      else
        return []
      end
    end
  end
end