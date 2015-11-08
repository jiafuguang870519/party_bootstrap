#coding : utf-8
module Fdn
  class Role < ActiveRecord::Base
    has_and_belongs_to_many :users, join_table:'roles_users'
    has_and_belongs_to_many :rights, join_table:'rights_roles'

    belongs_to :organization

    attr_accessor :zzz_org_name_cont

    scope :available, -> {where("fdn_roles.code != 'ghost'")}
    validates_uniqueness_of :name, :scope => [:organization_id]
    validates_uniqueness_of :code, :scope => [:organization_id]

    ROLE_ENT_REFORM = ['reform_sj', 'reform_qg', 'reform_cq', 'reform_kp']
    DEFAULT_ADMIN_ROLES = [{:factory => :admin_role}]

    DEFAULT_ADV_ROLES = [
        {:factory => :manager_role, :count => 1}
    ]

    DEFAULT_USER_ROLES = [
        {:factory => :user_role}
    ]

    scope :in_reform, -> { where(" code in (?)", ROLE_ENT_REFORM) }

    #after_create :ac
    #after_update :au

    #def ac
    #  Wf::Role.create(:resource => self, :name => "#{self.organization.code}.#{self.code}", :status => 'Y')
    #end
    #
    #def au
    #  users.each do |u|
    #    r = Wf::Role.find_by_resource_id_and_resource_type self.id, 'Fdn::Role'
    #    if r
    #      if r.fdn_users.detect { |us| us.id == u.id }.blank?
    #        Wf::User.create(:user_id => u.id, :role_id => r.id, :status => 'Y')
    #      end
    #    else
    #      r = Wf::Role.create(:resource => self, :name => "#{self.organization.code}.#{self.code}", :status => 'Y')
    #      Wf::User.create(:user_id => u.id, :role_id => r.id, :status => 'Y')
    #    end
    #  end
    #end

    def self.role_in_reform
      in_reform.map { |p| p.code }.join(",")
    end

    def self.init_role_with_org_and_user(organization, user, roles, rights)
      roles.each do |r|
        if r[:count].blank?
          role = organization.roles.create(FactoryGirl.attributes_for(r[:factory]))
          role.rights << rights
          if user
            user.roles << role
          end
        else
          if r[:count].to_i > 0
            for i in 1..r[:count].to_i do
              role = organization.roles.create(FactoryGirl.attributes_for(r[:factory], count: i))
              role.rights << rights
              if user
                user.roles << role
              end
            end
          else
            role = organization.roles.create(FactoryGirl.attributes_for(r[:factory], count: r[:count]))
            role.rights << rights
            if user
              user.roles << role
            end
          end
        end
      end
    end

    def self.update_role_with_rights(organization, role_code, rights)
      role = organization.roles.detect { |role| role.code == role_code }
      if role
        role.rights.clear
        role.rights << rights
      end
    end
  end
end

# == Schema Information
#
# Table name: fdn_roles
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)
#  code        :string(255)
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  created_by  :integer(4)
#  updated_by  :integer(4)
#

