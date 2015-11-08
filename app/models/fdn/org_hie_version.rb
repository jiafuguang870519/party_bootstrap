module Fdn
  class OrgHieVersion < ActiveRecord::Base
    belongs_to :org_hierarchy
    belongs_to :resource, :polymorphic => true

    has_many :org_hie_elements, :dependent => :destroy do
      def by_parent_id(org_id)
        where("parent_id = ?", org_id)
      end

      def by_child_id(org_id)
        where("child_id = ?", org_id)
      end

      def by_parent_and_child(parent_id, child_id)
        where("parent_id = ? and child_id = ?", parent_id, child_id)
      end

      def by_parent_ids(org_ids)
        where("parent_id in (?)", org_ids)
      end

      def by_child_ids(org_ids)
        where("child_id in (?)", org_ids)
      end

      def by_parents_and_children(parent_ids, child_ids)
        where("parent_id in (?) and child_id in (?)", parent_ids, child_ids)
      end
    end

    has_one :root_element, :class_name => 'Fdn::OrgHieElement', :conditions => 'parent_id = child_id and child_id = root_id and distance = 0'

    before_create :bc

    def bc
      self.lock_version=0
    end

    #结束一个版本
    def end_ver
      self.current_flag = 0
      self.end_date = Date.yesterday
      self.end_date = self.start_date if self.end_date.to_date < self.start_date.to_date
    end

    #开始一个版本
    def start_ver
      self.end_date = nil
      self.start_date = Date.today
      self.current_flag = 1
    end

    #开始第一个版本
    def self.start_new
      Fdn::OrgHieVersion.new(:ver=> 1).start_ver
    end

    def remove_org(org)
      old_descendants = org.descendants
      logger.info('begin remove org')
      logger.info("#{old_descendants.inspect}")

      self.org_hie_elements.by_parent_id(org.id).each do |e|
        Fdn::OrgHieElement.find(e.id).destroy
      end

      self.org_hie_elements.by_child_id(org.id).each do |e|
        Fdn::OrgHieElement.find(e.id).destroy
      end
      if old_descendants
        self.org_hie_elements.by_child_ids(old_descendants.values.flatten.map{|o| o.id}).each do |e|
          Fdn::OrgHieElement.find(e.id).destroy
        end
      end
    end

    def remove_elements(parent_ids, child_ids)
      self.org_hie_elements.by_parents_and_children(parent_ids, child_ids).each do |e|
        Fdn::OrgHieElement.find(e.id).destroy
      end
    end

    def add_elements(parent, childs, distance)
      childs.each do |child|
        org_hie_elements.create(:parent_id=>parent.id, :child_id=>child[0], :root_id=>parent.root.id, :distance=>distance,:seq=>child[1])
      end
    end
  end
end
# == Schema Information
#
# Table name: fdn_org_hie_versions
#
#  id               :integer(4)      not null, primary key
#  org_hierarchy_id :integer(4)
#  ver              :integer(4)
#  start_date       :date
#  end_date         :date
#  current_flag     :integer(4)
#  version          :integer(4)
#  created_at       :datetime
#  updated_at       :datetime
#  created_by       :integer(4)
#  updated_by       :integer(4)
#

