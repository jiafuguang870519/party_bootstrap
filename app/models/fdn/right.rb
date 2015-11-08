module Fdn
  class Right < ActiveRecord::Base
    has_and_belongs_to_many :roles, join_table:'rights_roles'

    validates_uniqueness_of :code, :scope => [:type_code, :app_code]

    COMMON = ['index', 'show', 'new', 'edit', 'delete']

    scope :in_menu, -> { where("menu_id is not null") }
    scope :by_menu, proc { |menu_id| where('fdn_rights.menu_id = ?', menu_id) }
    scope :in_menu_codes, proc {|codes| where("fdn_rights.menu_id in (select id from fdn_menus where fdn_menus.code in (?))", codes)}
    scope :not_in_menu_codes, proc { |codes| where("not exists
                                                    (select 1 from fdn_menus
                                                    where fdn_rights.menu_id = fdn_menus.id
                                                    and fdn_menus.code in (?) )", codes) }
    scope :not_in, lambda { |ids| where('fdn_rights.menu_id not in (?)', ids) }
    scope :menu_id_in, lambda { |ids| where('fdn_rights.menu_id in (?)', ids) }
    belongs_to :right_type, :class_name=>'Fdn::Lookups::RightType', :foreign_key => 'type_code', :primary_key => 'code'
    belongs_to :right_inst, :class_name=>'Fdn::Lookups::RightInst', :foreign_key => 'code', :primary_key => 'code'
    belongs_to :app, :class_name=>'Fdn::Lookups::App', :foreign_key => 'app_code', :primary_key => 'code'

    #权利中文说明 默认取说明，说明为空取权利的通用解释，通用解释为空取code
    def rigt_desc
      if !description.blank?
        return description
      elsif right_inst
        return right_inst.value
      else
        return code
      end
    end

    def parent_id
      Fdn::Menu.find(self.menu_id).parent_id
    end
    def menu_name
      Fdn::Menu.find(self.menu_id).name
    end

    def grandp_id
      Fdn::Menu.find(self.parent_id).parent_id
    end

  end
end

# == Schema Information
#
# Table name: fdn_rights
#
#  id          :integer(4)      not null, primary key
#  code        :string(255)
#  type_code   :string(255)
#  description :string(255)
#  app_code    :string(255)
#  controller  :string(255)
#  action      :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

