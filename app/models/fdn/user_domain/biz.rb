module Fdn::UserDomain::Biz
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      has_many :wf_users, :class_name => 'Wf::User', :foreign_key => 'user_id'
      has_many :wf_roles, :class_name => 'wf::Role', :through => :wf_users, :source => :role
      has_many :wf_activities, :class_name => 'Wf::Activity', :through => :wf_users
      scope :by_wf_role, lambda { |resource_type, codes| joins(:wf_roles).where(
          "wf_roles.resource_type=? and wf_roles.name in (?)", resource_type, codes
      ) }
    end
  end

  module ClassMethods
    #取流程中所有用户
    def get_process_users(process_id)
      Wf::Process.find_by_id(process_id).fdn_users.select("distinct fdn_users.*")
    end

    #取流程中当前操作用户
    def get_process_act_users(process_id)
      get_process_users(process_id).where("wf_activities.act_time is null")
    end

    ################################
    # Wf
    def find_by_wf_username(wf_username)
      code = wf_username.split('.')[0]
      name = wf_username.split('.')[1]
      Fdn::User.joins(:org).where("fdn_users.username=? and fdn_organizations.code=?", name, code).first
    end
  end

  ################################
  # Wf
  def wf_username
    "#{self.resource.code}.#{self.username}"
  end

  #################################
  def org_name_and_full_name(seperator='-')
    [self.org.name, self.full_name].join(seperator)
  end

  ################################
  # current org's descendants sql
  def curr_org_descendants_sql(table_name, column_name, type = 'ent')
    descendants_sql = Fdn::Organization.s_descendants(Fdn::OrgHierarchy.main.first.id, Time.now, self.resource_id).select_ent.to_sql
    self_ent_sql = self.resource.is_ent? ? " or #{table_name}.#{column_name} = #{self.resource.resource_id}" : ''

    "(#{table_name}.#{column_name} in (select #{type == 'ent' ? 'p.resource_id' : 'p.id'} from (#{descendants_sql}) p) #{self_ent_sql})"
  end
end