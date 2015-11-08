module Fdn
  class OrgHieElement < ActiveRecord::Base
    validates_presence_of :org_hierarchy_id, :parent_id, :child_id, :root_id, :distance
    NEVER_END_TIME = '2999-12-31 23:59:59'

    acts_as_list :column=> :seq, :scope=>'org_hierarchy_id=\'#{org_hierarchy_id}\' and parent_id=\'#{parent_id}\'and distance=\'#{distance}\' '
    scope :dup, proc {|org_hirarchy_id,
        parent_id,
        child_id,
        root_id,
        distance| where('org_hierarchy_id = ? and parent_id = ? and child_id = ? and root_id = ? and distance = ? and start_time is not null
                         and end_time is not null',
                        org_hirarchy_id, parent_id, child_id, root_id, distance).order('start_time, end_time')}

    scope :need_disabled_by_child, proc {|org_hierarchy_id, child_id, time|
      where('org_hierarchy_id = ? and child_id = ? and ? between start_time and end_time',
            org_hierarchy_id, child_id, time)}

    scope :need_disabled_by_parent, proc {|org_hierarchy_id, parent_id, time|
      where('org_hierarchy_id = ? and parent_id = ? and ? between start_time and end_time',
            org_hierarchy_id, parent_id, time)
    }

    #belongs_to :org_hie_version
    belongs_to :org_hierarchy
    belongs_to :parent, :class_name => 'Fdn::Organization', :foreign_key => 'parent_id'
    belongs_to :child, :class_name => 'Fdn::Organization', :foreign_key => 'child_id'
    belongs_to :root, :class_name => 'Fdn::Organization', :foreign_key => 'root_id'

    def disable(time)
      if self.end_time.strftime(Fdn::Lookup::LONG_TIME) == NEVER_END_TIME && self.start_time < time
        self.end_time = time.ago(1)
        self.save
      else
        raise 'Illegal time, must between enabled start_time and end_time.'
      end
    end

    def enable(time)
      if self.valid?
        if dup = Fdn::OrgHieElement.dup(self.org_hierarchy_id, self.parent_id, self.child_id, self.root_id, self.distance)
          #logger.info dup.first.start_time
          #logger.info dup.last.end_time
          #logger.info time
          #以前有记录
          if dup.size >= 1
            if time < dup.first.start_time
              self.start_time = time
              self.end_time = dup.first.start_time.ago(1)
            elsif time > dup.last.end_time
              self.start_time = time
              self.end_time = NEVER_END_TIME
            else
              raise 'Illegal time, must be earlier than the first record or later than the last record.'
            end
          #第一条记录
          else
            self.start_time = time
            self.end_time = NEVER_END_TIME
          end
        else
          raise 'Illegal query!'
        end
        self.save
      else
        raise 'Illegal record!'
      end
    end
    #def self.update_root(root_id, version_id)
    #  update_all(:root_id=> root_id).where("org_hie_version_id=?", version_id)
    #end
  end
end
# == Schema Information
#
# Table name: fdn_org_hie_elements
#
#  id                 :integer(4)      not null, primary key
#  org_hie_version_id :integer(4)
#  parent_id          :integer(4)
#  child_id           :integer(4)
#  root_id            :integer(4)
#  distance           :integer(4)
#  seq                :integer(4)
#  created_at         :datetime
#  updated_at         :datetime
#

