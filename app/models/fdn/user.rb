#coding: utf-8
module Fdn
  class User < ActiveRecord::Base
    attr_accessor :curr_assignment,:zzz_org_name_cont
    liquid_methods :person

    include Fdn::UserDomain::Homepage
    include Fdn::UserDomain::Message
    include Fdn::UserDomain::PredefOpinion
    include Fdn::UserDomain::Hr
    include Fdn::UserDomain::Sms
    include Fdn::UserDomain::Biz


    #自定义accept_nested_attributes_for 的 write方法，放在module 中不能使用。。。
    #删除为空的意见行
    def predef_opinions_attributes=(attributes)
      attributes.each do |key, value|
        if value.has_key?(:content) && !value[:content].blank?
          predef_opinions.build(value)
        end
      end
    end

    #validates_uniqueness_of :username, :scope => [:resource_id, :resource_type]

    acts_as_authentic do |c|
      c.crypted_password_field('encrypted_password')
      c.validations_scope([:resource_id, :resource_type])
    end

    has_many :fdn_talks, :class_name => 'Fdn::Talk'

    has_many :fdn_commentses, :class_name => 'Fdn::Comments'

    belongs_to :org, :class_name=>'Fdn::Organization', :foreign_key=>'resource_id'
    belongs_to :resource, :polymorphic => true

    has_and_belongs_to_many :roles, join_table: 'roles_users'
    has_many :rights, :through => :roles

    has_one :user_information, :class_name => 'Fdn::UserInformation'
    accepts_nested_attributes_for :user_information

    delegate :full_name, :to => 'user_information'
    belongs_to :person, :class_name => 'Hr::Person', :foreign_key => 'person_id'

    has_and_belongs_to_many :enterprises, join_table:'users_enterprises'

    has_many :jq_users, class_name:'Fdn::JqUser', foreign_key:'resource_id'
    accepts_nested_attributes_for :jq_users

    has_many :cq_users,-> { where("resource_type = 'cq_user'")}, class_name:'Fdn::JqUser', foreign_key:'resource_id'
    accepts_nested_attributes_for :cq_users
    has_many :kb_users,-> { where("resource_type = 'kb_user'")}, class_name:'Fdn::JqUser', foreign_key:'resource_id'
    accepts_nested_attributes_for :kb_users
    has_many :nb_users,-> { where("resource_type = 'nb_user'")}, class_name:'Fdn::JqUser', foreign_key:'resource_id'
    accepts_nested_attributes_for :nb_users
    has_many :ys_users,-> { where("resource_type = 'ys_user'")}, class_name:'Fdn::JqUser', foreign_key:'resource_id'
    accepts_nested_attributes_for :ys_users
    has_many :js_users,-> { where("resource_type = 'js_user'")}, class_name:'Fdn::JqUser', foreign_key:'resource_id'
    accepts_nested_attributes_for :js_users

    def has_role

    end

    def cq_user
      users = self.cq_users.show
      if users.size != 1
        return ''
      else
        if self.org.resource_type == 'Fdn::Dept' && self.org.resource.type_code == 'GZW'
          return users.first.user_name
        elsif self.org.code == users.first.user_name
          return users.first.user_name
        else
          return ''
        end
      end
    end

    def kb_user
      users = self.kb_users.show
      if users.size != 1
        return ''
      else
        if self.org.resource_type == 'Fdn::Dept' && self.org.resource.type_code == 'GZW'
          return users.first.user_name
        elsif self.org.code == users.first.user_name.chop
          return users.first.user_name
        else
          return ''
        end
      end
    end

    def nb_user
      users = self.nb_users.show
      if users.size != 1
        return ''
      else
        if self.org.resource_type == 'Fdn::Dept' && self.org.resource.type_code == 'GZW'
          return users.first.user_name
        elsif self.org.code == users.first.user_name[2,9]
          return users.first.user_name
        else
          return ''
        end
      end
    end

    def ys_user
      users = self.ys_users.show
      if users.size != 1
        return ''
      else
        if self.org.resource_type == 'Fdn::Dept' && self.org.resource.type_code == 'GZW'
          return users.first.user_name
        elsif self.org.code == users.first.user_name[2,9]
          return users.first.user_name
        else
          return ''
        end
      end
    end

    def js_user
      users = self.js_users.show
      if users.size != 1
        return ''
      else
        return users.first.user_name
      end
    end

    has_many :dashboards do
      def actived
        where('fdn_dashboards.active = 1')
      end
    end
    accepts_nested_attributes_for :dashboards

    scope :available, -> { where("fdn_users.status = 'Y' and fdn_users.ghost = 'N'") }
    scope :show, -> { where("fdn_users.ghost = 'N'") }
    scope :employee, -> { where("fdn_users.person_id is not null") }

    scope :except_ids, lambda { |user_ids| where('fdn_users.id not in (?)', user_ids) }
    scope :include_ids, lambda { |user_ids| where('fdn_users.id in (?)', user_ids) }

    scope :by_role_codes, lambda { |codes| joins(:roles).where("fdn_roles.code in (?)", codes).distinct }#.select('distinct fdn_users.id').map {|x| Fdn::User.find x} }#.select('distinct fdn_users.*') }

    scope :by_org_ids, lambda { |org_ids| where("fdn_users.resource_id in (?) and fdn_users.resource_type = 'Fdn::Organization'", org_ids) }
    scope :by_org_id, proc { |org_id| where("resource_id=? and resource_type='Fdn::Organization'", org_id) }

    scope :username_like, lambda { |username| where("fdn_users.username like ?", "%#{username}%") }
    scope :fullname_like, lambda { |full_name| includes(:user_information).where("fdn_user_informations.full_name like ?", "%#{full_name}%") }

    scope :auth, lambda { |org_code, username| joins(:org).where("fdn_organizations.code = ? and fdn_users.username = ?", org_code, username) }

    #scope :by_per_name, lambda { |full_name| join_per.where("hr_people.full_name=?", full_name) }
    scope :like_full_name, proc { |full_name| includes(:user_information).where("fdn_user_informations.full_name like ?", "%#{full_name}%") }
    scope :like_user_name, proc { |user_name| where("username like ?", "%#{user_name}%") }
    after_create :ac
    before_create :bc

    after_update :au


    def bc
      self.status = 'Y' if self.status.blank?
    end

    def ac
      #Fdn::PredefOpinionTemplate.all.each do |t|
      #  self.predef_opinions.create(:type_code => t.type_code, :content => t.content)
      #end

      #r = Wf::Role.create(:resource => self, :name => "#{self.resource.code}.#{self.username}", :status => 'Y')
      #Wf::User.create(:user_id => self.id, :role_id => r.id, :status => 'Y')
    end

    def au
      #roles.each do |r|
      #  wf_r = Wf::Role.find_by_resource_id_and_resource_type(r.id, 'Fdn::Role')
      #  if wf_r
      #    if wf_r.fdn_users.detect { |u| u.id == self.id }.blank?
      #      Wf::User.create(:user_id => self.id, :role_id => wf_r.id, :status => 'Y')
      #    end
      #  else
      #    wf_r = Wf::Role.create(:resource => r, :name => "#{r.organization.code}.#{r.code}", :status => 'Y')
      #    Wf::User.create(:user_id => self.id, :role_id => wf_r.id, :status => 'Y')
      #  end
      #end
    end

    #使用这个方法来创建动态方法
    #如果是判断角色用 is_a_xxxx_or_yyyy_or_zzzz? 来表达，其中xxxx,yyyy,zzzz是角色的code
    #如果是判断权利用 can_xxxx_or_yyyy_or_zzzz? 来表达，其中xxxx,yyyy,zzzz是权利的code_type_code或action_controller的结合
    #如果是判断处室用 in_dept_of_xxxx_or_yyyy_or_zzzz? 来表达，其中xxxx,yyyy,zzzz是处室code的小写
    #如果是判断职位用 in_pos_of_xxxx_or_yyyy_or_zzzz? 来表达，其中xxxx,yyyy,zzzz是职位code的小写，将.转为_
    #如果是判断职务用 in_job_of_xxxx_or_yyyy_or_zzzz? 来表达，其中xxxx,yyyy,zzzz是职务code的小写，将.转为_
    #如果是判断数据安全性用 query_xxx 来表达，其中xxx是fdn_data_securities的code，返回resource的数组
    #在view和controller中对功能加权限控制
    def method_missing(method_id, *args)
      if match = has_role?(method_id)
        split_string(match.captures.first).each do |role|
          return true if roles.detect { |fdn_role| fdn_role.code == role }
        end
        return false
      elsif match = has_right?(method_id)
        #logger.info("match info :#{match.inspect}")
        split_string(match.captures.first).each do |right|
          #logger.info("rights, #{rights.map{|r| [r.code, r.type_code]}.inspect}")
          #logger.info("right: #{right}")
          #logger.info("result : #{rights.detect { |fdn_right| fdn_right.code == right || "#{fdn_right.action.blank? ? fdn_right.code : fdn_right.action}_#{fdn_right.controller.blank? ? fdn_right.type_code : fdn_right.controller}" == right }}")
          return true if rights.detect { |fdn_right| "#{fdn_right.code}_#{fdn_right.type_code}" == right || "#{fdn_right.action.blank? ? fdn_right.code : fdn_right.action}_#{fdn_right.controller.blank? ? fdn_right.type_code : fdn_right.controller}" == right }
        end
        return false
      elsif match = in_dept?(method_id)
        dept_codes = []
        split_string(match.captures.first).each do |dept|
          dept_codes << dept.upcase
          logger.info("happen: #{dept_codes}")
        end
        users = Fdn::User.by_dept_code(dept_codes)
        !users.empty? && users.detect { |u| u.id == self.id }
      elsif match = in_pos?(method_id)
        pos_codes = []
        split_string(match.captures.first).each do |pos|
          pos_codes << pos.upcase.gsub(/_/, '.')
        end
        users = Fdn::User.by_pos_code(pos_codes)
        !users.empty? && users.detect { |u| u.id == self.id }
      elsif match = in_job?(method_id)
        job_codes = []
        split_string(match.captures.first).each do |job|
          job_codes << job.upcase.gsub(/_/, '.')
        end
        users = Fdn::User.by_job_code(job_codes)
        !users.empty? && users.detect { |u| u.id == self.id }
      elsif match = in_query?(method_id)
        Fdn::DataSecurity.find_all_by_code_and_role_code(match.captures.first, self.roles.map { |r| r.code }).map { |o| o.resource }
      else
        super
      end
    end


    ################################
    # authlogic
    def active?
      self.status == 'Y'
    end

    #login_method
    def self.find_by_org_and_username(value)
      org_code = value[0..value.index('_')-1]
      username = value.from(value.index('_')+1)
      auth(org_code, username).first
    end
    ##################################

    def self.more_search(org_id, add_params, page=nil, limit=nil)
      if page
        r = Fdn::User.paginate(:page => page).order('seq, username')
      elsif limit
        r = Fdn::User.order('seq, username').limit(limit)
      else
        r = Fdn::User.order('seq, username')
      end

      r = r.by_org_id(org_id)
      r
    end
    #validate :user_error
    #
    #def user_error(value=false)
    #  if value
    #    errors.add(:base, "帐号列表-同一类型的帐号中存在多个当前帐号，请重新输入！")
    #  end
    #end

    private

    #以下3个方法为method_missing使用，检查角色和权利
    def has_role?(method_id)
      /^is_an?_([a-zA-Z]\w*)\?$/.match(method_id.to_s)
    end

    def split_string(string_to_split)
      string_to_split.split(/_or_/)
    end

    def has_right?(method_id)
      /^can_([a-zA-Z]\w*)\?$/.match(method_id.to_s)
    end

    def in_dept?(method_id)
      /^in_dept_of_([a-zA-Z]\w*)\?$/.match(method_id.to_s)
    end

    def in_pos?(method_id)
      /^in_pos_of_([a-zA-Z]\w*)\?$/.match(method_id.to_s)
    end

    def in_job?(method_id)
      /^in_job_of_([a-zA-Z]\w*)\?$/.match(method_id.to_s)
    end

    def in_query?(method_id)
      /^query_([a-zA-Z]\w*)$/.match(method_id.to_s)
    end

  end
end

# == Schema Information
#
# Table name: fdn_users
#
#  id                  :integer(4)      not null, primary key
#  username            :string(255)     not null
#  encrypted_password  :string(255)     not null
#  password_salt       :string(255)     not null
#  persistence_token   :string(255)     not null
#  single_access_token :string(255)     not null
#  perishable_token    :string(255)     not null
#  resource_type       :string(255)
#  resource_id         :integer(4)
#  login_count         :integer(4)      default(0), not null
#  failed_login_count  :integer(4)      default(0), not null
#  last_request_at     :datetime
#  current_login_at    :datetime
#  last_login_at       :datetime
#  current_login_ip    :string(255)
#  last_login_ip       :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  created_by          :integer(4)
#  updated_by          :integer(4)
#

