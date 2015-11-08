module Fdn
  class OrgHierarchy < ActiveRecord::Base
    OA_HIE_MAIN = 'OA_MAIN'

    attr_accessor :org_name
    #OA_HIE_PARTY = 'OA_PARTY'
    #
    #Deprecation:
    #在org_hie_elements中加入时间的概念，取消org_hie_versions 及所有和version有关的程序
    #has_many :org_hie_versions, :class_name=>'Fdn::OrgHieVersion', :dependent => :destroy do
    #  def by_ver(ver)
    #    where("ver = ?", ver).first
    #  end
    #end
    #has_one :curr_ver, :class_name=>'Fdn::OrgHieVersion', :conditions => 'current_flag=1'

    has_many :org_hie_elements, :class_name => 'Fdn::OrgHieElement'#, :order => 'seq'

    belongs_to :org, :class_name => 'Fdn::Organization',:foreign_key => 'org_id'

    #has_one :root_element
    #
    #delegate :root, :to=> :root_element
    #
    scope :main, -> { where('main_flag=1') }

    before_create :bc
    
    def bc
      #self.lock_version= 0
      #self.curr_ver ||= Fdn::OrgHieVersion.new
      #self.curr_ver.org_hierarchy_id = self.id
      #self.curr_ver.ver = 1
      #self.curr_ver.start_date = Time.now
      #self.curr_ver.current_flag = 1
    end

    #从最新的版本中拷贝生成新版本，如果没有当前版本则自动创建一个新版本
    #def copy_from_latest(with_element=true)
    #  latest = self.curr_ver
    #  if latest
    #    new = OrgHieVersion.new(latest.attributes)
    #    if with_element
    #      latest.org_hie_elements.each do |e|
    #        new.org_hie_elements.build(e.attributes.delete_if { |k, v| k == 'org_hie_version_id' })
    #      end
    #    end
    #
    #    latest.end_ver
    #    new.start_ver
    #    new.ver = latest.ver + 1
    #    latest.save
    #    new.save
    #  else
    #    self.org_hie_versions << Fdn::OrgHieVersion.start_new
    #    self.save
    #  end
    #end

  end
end
# == Schema Information
#
# Table name: fdn_org_hierarchies
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  code       :string(255)
#  main_flag  :integer(4)
#  version    :integer(4)
#  created_at :datetime
#  updated_at :datetime
#  created_by :integer(4)
#  updated_by :integer(4)
#

