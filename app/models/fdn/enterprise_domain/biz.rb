module Fdn::EnterpriseDomain::Biz
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      after_create :ac
    end
  end

  module ClassMethods
    def build_from_main_inv_org(main_inv_org_id, is_foreign, ent_code=nil)
      if ent_code
        ent = new(:main_inv_org_id => main_inv_org_id, :is_foreign => is_foreign, ent_code:ent_code)
      else
        ent = new(:main_inv_org_id => main_inv_org_id, :is_foreign => is_foreign)
      end
      ent.generate_with_main_inv_org
      ent.build_organization
      ent
    end
  end

  def ac
    #奇怪TODO
    p 'aaa'
    p self.organization.id
    self.exchange_rate = 0 if self.exchange_rate.blank?
    self.save
    p 'bbb'
    p self.organization.id
    self.gov_inv_id = self.organization.id if !self.gov_inv_id
    self.save
  end

  def generate_with_main_inv_org
    if main_inv_org.resource_type == 'Fdn::Enterprise'
      self.gov_inv_id = main_inv_org.resource.gov_inv_id
      self.sasac_dept_id = main_inv_org.resource.sasac_dept_id
      self.dept_id = main_inv_org.resource.dept_id
      self.ent_level_code = main_inv_org.resource.ent_level_code.to_i+1
      #logger.info("is foreign :#{self.is_foreign}")
      #logger.info("self.main_inv_org.resource_type #{self.main_inv_org.resource_type}")
      #logger.info("self.main_inv_org.resource.is_foreign #{self.main_inv_org.resource.is_foreign}")

      if main_inv_org.resource.is_foreign == 1 && self.is_foreign != 1
        self.is_outside_to_inside = 1
      else
        self.is_outside_to_inside = 0
      end

    elsif main_inv_org.resource_type == 'Fdn::Dept'
      case main_inv_org.resource.type_code
        when 'GZW'
          self.sasac_dept_id = main_inv_org.id
          self.dept_id = main_inv_org.id
          self.ent_level_code = '1'
          self.is_outside_to_inside = 0
        when 'GOV'
          self.sasac_dept_id = main_inv_org.with_hierarchy.curr_sasac.id
          self.dept_id = main_inv_org.id
          self.ent_level_code = '1'
          self.is_outside_to_inside = 0
        when 'VIR'
          self.dept_id = main_inv_org.with_hierarchy.curr_gov_dept.id
          self.sasac_dept_id = main_inv_org.with_hierarchy.curr_sasac.id
          self.gov_inv_id = main_inv_org.ent_supervisor.id if main_inv_org.ent_supervisor
          if main_inv_org.nearest_parent_ent
            self.ent_level_code = main_inv_org.nearest_parent_ent.resource.ent_level_code.to_i+1
            if main_inv_org.nearest_parent_ent.resource.is_foreign == 1 && self.is_foreign != 1
              self.is_outside_to_inside = 1
            else
              self.is_outside_to_inside = 0
            end
          else
            self.is_outside_to_inside = 0
            self.ent_level_code = '1'
          end
        else
          raise 'Organization resource type error.'
      end
    end
  end
end