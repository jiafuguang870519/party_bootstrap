module Fdn
  class Dept < ActiveRecord::Base
    #acts_as_flex_attr

    has_one :organization, :as=>:resource, :dependent=>:destroy
    accepts_nested_attributes_for :organization, :allow_destroy=>true

    belongs_to :dept_type, :class_name => 'Fdn::Lookups::DeptType', :foreign_key => 'type_code', :primary_key => 'code'

    scope :internal, -> { where('internal = 1') }
    scope :include_ids, lambda {|depts_ids| where('fdn_depts.id in (?)', depts_ids)}
    scope :sasac , -> { where('type_code = \'GZW\'') }
    scope :govs , -> { where('type_code = \'GOV\'') }

    def dept_name
      organization.name
    end

    def dept_short_name
      organization.short_name
    end

    def dept_code
      organization.code
    end

    def compare_dept
      @dept_latest = Fdn::DeptHistory.where("dept_id =?",self.id).order("start_time DESC").first
      @org = self.organization
      @org_his = Fdn::OrganizationHistory.where("resource_type = \'Fdn::DeptHistory\' and resource_id = ?",@dept_latest.id).first
      str = true
      if self.type_code != @dept_latest.type_code
        str = false
      end
      if self.id != @dept_latest.dept_id
        str = false
      end
      if self.seq != @dept_latest.seq
        str = false
      end
      if self.internal != @dept_latest.internal
        str = false
      end
      if @org.name != @org_his.name
        str = false
      end
      if @org.code != @org_his.code
        str = false
      end
      if @org.short_name != @org_his.short_name
        str = false
      end
      if @org.description != @org_his.description
        str = false
      end
      return str
    end

    def history
      result = self.compare_dept
      if result == false
        @dept_latest = Fdn::DeptHistory.where("dept_id =?",self.id).order("start_time DESC").first
        if @dept_latest != nil
          time = Time.now.to_i
          @dept_latest.end_time = Time.at(time-1)
          @dept_latest.save
        end
        @dept_his = Fdn::DeptHistory.new
        @dept_his.copy_data(self)
      end
    end

    def update_history
      @dept_latest = Fdn::DeptHistory.where("dept_id =?",self.id).order("start_time DESC").first
      if @dept_latest.nil?
        @dept_latest = Fdn::DeptHistory.new(:dept_id=>self.id)
      end
      @dept_latest.copy_data(self)
    end

    #用户按照部门分组
    def self.dept_users_conllection(opts={})
      default_opts = {:name_attr=>'full_name', :value_attr=>'user_id'}
      opts = default_opts.merge(opts)
      @depts = Fdn::Dept.internal
      count = 0
      grouped_options = []
      if opts[:pre_collection]
        grouped_options << opts[:pre_collection]        
        count = grouped_options.size        
      end
      @depts.each do |dept|
        @users = dept.organization.people.collect { |user| [ user.send(opts[:name_attr]), user.send(opts[:value_attr])]  }
        grouped_options[count] =  [dept.organization.name, @users]
        count += 1
      end
      if opts[:suf_collection]
        grouped_options << opts[:suf_collection]
      end
      logger.info("options:#{grouped_options.inspect}")
      return grouped_options
    end

    #按照dept_ids顺序输出dept
    def self.dept_order_conllection(dept_ids)
      @depts = []
      if dept_ids.blank?
        @depts += Fdn::Dept.internal
      else
        dept_ids.each do |dept_id|
          @depts << Fdn::Dept.find(dept_id) unless dept_id.blank?
        end
        @depts += Fdn::Dept.internal.where("id not in (?)", dept_ids)
      end
      
      return @depts
    end
    
  end
end
# == Schema Information
#
# Table name: fdn_depts
#
#  id         :integer(4)      not null, primary key
#  seq        :integer(4)
#  internal   :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

