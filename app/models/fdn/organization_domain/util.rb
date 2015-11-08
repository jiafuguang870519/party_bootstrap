#coding: utf-8
module Fdn::OrganizationDomain::Util
  # To change this template use File | Settings | File Templates.
  def self.included(base)
    base.extend(ClassMethods)

    base.class_eval do
      include Fdn::OrganizationDomain::Util::InstanceMethods
    end
  end

  module ClassMethods

  end

  module InstanceMethods
    #####################fdn_jq_orgs
    def jb_zzxs
      {'11'=>'有限责任公司','12'=>'一人有限责任公司','13'=>'股份有限公司','14'=>'股份有限公司（上市）','15'=>'中外合资企业','21'=>'全民所有制企业','22'=>'集体企业','25'=>'有限合伙企业','31'=>'国家授权投资机构','33'=>'事业单位'}[FdnJqOrg.find_by(stdcode:self.std_code).jb_zzxs]
    end

    def jb_sshy
      FdnJqOrg.find_by(stdcode:self.std_code).jb_sshy.split(';').map{|ss| (lookup = Prs::Lookups::EntIndustry.find_by(code:ss)) ? lookup.value : '未定义'}.join(';')
    end
    #####################
    #企业修改 出资人自动带出出资人类别
    #001国有 002绝对 003实际 004参股
    #000国家 001国有 002绝对 003实际 004参股
    def inv_type_code
      self.is_ent? ? self.resource.ent_type_code : "000"
    end

    def inv_type_value
      Prs::Lookups::InvestorType.find_by_code(self.inv_type_code).value
    end

    #判断是否为重点监管企业
    def is_key_regulatory?
      !Aae::KeyRegulatorySetting.where("ent_id = ? and key_regulatory= 'Y'",self.id).blank?
    end


    #部门的上级
    def parent_dept_named
      self.parent.name if self.parent
    end

    def parent_dept_named=(value)

    end

    def is_ent?
      self.resource_type == "Fdn::Enterprise"
    end

    def only_ent_code
      self.resource_type == "Fdn::Dept" ? "" : self.code
    end

    # end attr_accessor
    ############################################################################
    def org_type_name
      if self.resource_type == 'Fdn::Enterprise'
        "企业"
      else
        self.resource.dept_type.value
      end
    end

    def org_type_code
      if self.resource_type == 'Fdn::Enterprise'
        "ENT"
      else
        self.resource.type_code
      end
    end

    def is_top?
      self.id.to_s == Fdn::Profile.get_value('TOP_SASAC')
    end

    def can_delete?(hierarchy_id,time=Time.now)
      self.with_hierarchy(hierarchy_id,time)
      if self.children.blank?
        return 'can_delete'
      else
        return 'no_delete'
      end
    end

    def using_tree(time)
      value = ''
      if  self.resource_type == 'Fdn::Enterprise'
        Fdn::OrgHierarchy.all.each do |hie|
          if self.with_hierarchy(hie.id,time).parent
            value += "<span class='badge #{hie.icon}'>"+hie.short_name+"</span>"
          end
        end
      end
      return value.html_safe
    end
  end
end