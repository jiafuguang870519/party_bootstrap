#coding: utf-8
module Fdn::EnterpriseDomain::Validator
  def self.included(base)
    base.extend(ClassMethods)

    base.class_eval do
      #validate :three_value, :on => :update
      #validate :inv_unique, :on => :update
      #validate :ent_code_validate
      #validate :inv_code_validate
      validates :ent_code, :uniqueness => true, :presence => true
      #validates :reg_amt, :presence => true
      include Fdn::EnterpriseDomain::Validator::InstanceMethods
    end
  end

  module ClassMethods

  end

  module InstanceMethods
    #rspec不识别enterprise表的方法。。。。。。。。。。。。。。。。。。。。
    def inv_code_validate
      if investors.size > 0
        total = 0
        state = 0
        control = 0
        investors.each do |i|
          total += i.amount
          state += i.amount if Prs::PropertyRight::STATE_INV_CODE.include?(i.org_type_code)
          control += i.amount if Prs::PropertyRight::CONTROL_INV_CODE.include?(i.org_type_code)
        end
        state_count = state/total
        control_count = control/total

        if ent_type_code == Prs::PropertyRight::STATE_ENT_CODE && state_count < 1
          errors.add(:base, "国有企业->国家和国有出资股份应等于100%！")
        end

        if ent_type_code == Prs::PropertyRight::CONTROL_ENT_CODE && (control_count <= 0.5 || state_count == 1)
          errors.add(:base, "国有绝对控股企业->国有出资股份之和应大于50%！")
        end

        if ent_type_code == Prs::PropertyRight::ACTUAL_HOLD_ENT_CODE && (control_count > 0.5 || control_count == 0)
          errors.add(:base, "国有实际控制企业->国有出资股份之和应大于0%且小于等于50%！")
        end

        if ent_type_code == Prs::PropertyRight::SHARE_ENT_CODE && (control_count > 0.5 || control_count == 0)
          errors.add(:base, "国有参股企业->国有出资股份之和应大于0%且小于等于50%！")
        end

      end
    end

    #组织机构代码验证
    def ent_code_validate
      if self.is_reg == 1 && self.ent_code.blank? && self.is_foreign != 1
        errors.add(:ent_code, "如果已办工商，则必须填写组织机构代码！")
      else
        newcode = Fdn::OrgCode.new
        entcode = newcode.get_org_code(self.ent_code)
        self.ent_code = entcode if self.ent_code[0] == "L"
        if entcode != self.ent_code
          errors.add(:base, "组织机构代码输入有误，请确认！")
        end
      end

    end

    #验证注册资本和出资额总和
    def three_value
      a, fc= 0, 0
      investors.each do |r|
        a += r.amount||0
        fc += r.foreign_currency||0
      end
      ra= reg_amt||0
      rfc= foreign_currency||0

      unless ra == a && rfc == fc
        errors.add(:base, "出资额总和必须与注册资本相同！")
      end
    end

    #出资人唯一
    def inv_unique
      arr = []
      investors.each do |i|
        arr << i.investor_name
      end
      errors.add(:base, "出资人必须唯一！") if !arr.uniq!.blank?
    end

  end
end