#coding: utf-8
module Fdn::OrganizationDomain::Tree
  # To change this template use File | Settings | File Templates.
  def self.included(base)
    base.extend(ClassMethods)

    base.class_eval do
      attr_accessor :hierarchy_id, :eff_time, :seq

      scope :join_org_hierarchy, -> { joins('inner join fdn_org_hierarchies on fdn_org_hie_elements.org_hierarchy_id = fdn_org_hierarchies.id') }
      scope :effective_time, proc { |time| where(' ? between fdn_org_hie_elements.start_time and fdn_org_hie_elements.end_time', time) }
      scope :join_hierarchy_from_child, lambda { joins('inner join fdn_org_hie_elements on fdn_org_hie_elements.child_id = fdn_organizations.id').join_org_hierarchy }

      scope :join_hierarchy_from_parent, lambda { joins('inner join fdn_org_hie_elements on fdn_org_hie_elements.parent_id = fdn_organizations.id').join_org_hierarchy }

      scope :join_hierarchy_from_root, lambda { joins('inner join fdn_org_hie_elements on fdn_org_hie_elements.root_id = fdn_organizations.id').join_org_hierarchy }

      scope :where_hierarchy, lambda { |hierarchy_id, time| effective_time(time).where(
          'fdn_org_hierarchies.id=?', hierarchy_id
      ) }

      scope :select_hierarchy, proc { |time| select("fdn_organizations.*,
        fdn_org_hie_elements.distance f_distance,
        timestamp('#{time.strftime(Fdn::Lookup::LONG_TIME)}') f_time,
        fdn_org_hie_elements.org_hierarchy_id f_hierarchy_id,
        fdn_org_hie_elements.seq,
        fdn_org_hie_elements.id ele_id") }
      scope :select_direct_parent, proc { |time| select(" (select e.parent_id
        from fdn_org_hie_elements e
        where e.org_hierarchy_id= fdn_org_hierarchies.id
        and '#{time.strftime(Fdn::Lookup::LONG_TIME)}' between e.start_time and e.end_time
        and e.distance = 1
        and e.child_id = fdn_org_hie_elements.child_id) d_parent_id ") }
      scope :select_seq, proc { |time| select("(select e.seq
        from fdn_org_hie_elements e
        where e.org_hierarchy_id= fdn_org_hierarchies.id
        and '#{time.strftime(Fdn::Lookup::LONG_TIME)}' between e.start_time and e.end_time
        and e.distance = 1
        and e.child_id = fdn_org_hie_elements.child_id) f_seq") }

      scope :s_children, lambda { |hierarchy_id, time, parent_id| join_hierarchy_from_child.where_hierarchy(hierarchy_id, time).where(
          'fdn_org_hie_elements.parent_id=? and fdn_org_hie_elements.distance= 1', parent_id
      ).order('fdn_org_hie_elements.seq').select_hierarchy(time).select_seq(time) }

      #查询所有下级组织，选出直接上级和在此级次中的序号
      scope :s_descendants, lambda { |hierarchy_id, time, parent_id| join_hierarchy_from_child.where_hierarchy(hierarchy_id, time).where(
          'fdn_org_hie_elements.parent_id=? and fdn_org_hie_elements.distance >= 1', parent_id
      ).order('fdn_org_hie_elements.distance, f_seq').select_hierarchy(time).select_direct_parent(time).select_seq(time) }

      scope :s_children_by_dis, lambda { |hierarchy_id, time, parent_id, distance| join_hierarchy_from_child.where_hierarchy(hierarchy_id, time).where(
          'fdn_org_hie_elements.parent_id=? and fdn_org_hie_elements.distance = ?', parent_id, distance
      ).order('fdn_org_hie_elements.seq').select_hierarchy(time).select_seq(time) }

      scope :s_parent, lambda { |hierarchy_id, time, child_id| join_hierarchy_from_parent.where_hierarchy(hierarchy_id, time).where(
          'fdn_org_hie_elements.child_id=? and fdn_org_hie_elements.distance= 1', child_id
      ).select_hierarchy(time) }

      scope :s_ancestors, lambda { |hierarchy_id, time, child_id| join_hierarchy_from_parent.where_hierarchy(hierarchy_id, time).where(
          'fdn_org_hie_elements.child_id=? and fdn_org_hie_elements.distance >= 1', child_id
      ).order('fdn_org_hie_elements.distance').select_hierarchy(time) }

      scope :s_parent_by_dis, lambda { |hierarchy_id, time, child_id, distance| join_hierarchy_from_parent.where_hierarchy(hierarchy_id, time).where(
          'fdn_org_hie_elements.child_id=? and fdn_org_hie_elements.distance= ?', child_id, distance
      ).select_hierarchy(time) }

      scope :s_is_root, lambda { |hierarchy_id, time, child_id| join_hierarchy_from_root.where_hierarchy(hierarchy_id, time).where(
          'fdn_org_hie_elements.child_id=? and fdn_org_hie_elements.distance < 1', child_id
      ).select_hierarchy(time) }

      after_find :af
      include Fdn::OrganizationDomain::Tree::InstanceMethods
    end
  end

  module ClassMethods
    #在两个层次之间复制树，开始节点必须在两个层次中都存在
    def dump_between_hie(from_hie_id, to_hie_id, time, from_org_id)

      to_org = Fdn::Organization.find(from_org_id).with_hierarchy(to_hie_id, time)
      from_org = Fdn::Organization.find(from_org_id).with_hierarchy(from_hie_id, time)

      from_org.children.each do |o|
        to_org.add_child(o.id)
        dump_between_hie(from_hie_id, to_hie_id, time, o.id)
      end
    end
  end

  module InstanceMethods
    def af
      self.eff_time = self.f_time if self.respond_to?('f_time')
      self.hierarchy_id = self.f_hierarchy_id if self.respond_to?('f_hierarchy_id')
      self.seq = self.f_seq if self.respond_to?('f_seq')
    end

    def with_hierarchy(hierarchy_id=nil, time=Time.now)
      self.hierarchy_id = hierarchy_id || Fdn::OrgHierarchy.main.first.id
      self.eff_time = time
      self
    end

    #直接下级组织
    def children
      self.with_hierarchy unless self.hierarchy_id && self.eff_time
      Fdn::Organization.s_children(self.hierarchy_id, self.eff_time, self.id)
    end

    #所有下级组织，结果为按距离和seq排序的数组
    def all_descendants
      self.with_hierarchy unless self.hierarchy_id && self.eff_time
      Fdn::Organization.s_descendants(self.hierarchy_id, self.eff_time, self.id)
    end

    #直接上级组织
    def parent
      self.with_hierarchy unless self.hierarchy_id && self.eff_time
      if orgs = Fdn::Organization.s_parent(self.hierarchy_id, self.eff_time, self.id)
        orgs.first
      end
    end

    #最上级组织
    def root
      self.with_hierarchy unless self.hierarchy_id && self.eff_time
      return self if root?
      if orgs = Fdn::Organization.s_ancestors(self.hierarchy_id, self.eff_time, self.id)
        orgs.last
      end

    end

    #本组织是否最上级组织
    def root?
      self.with_hierarchy unless self.hierarchy_id && self.eff_time
      if orgs = Fdn::Organization.s_is_root(self.hierarchy_id, self.eff_time, self.id)
        !orgs.empty?
      end

    end

    #所有上级组织
    def ancestors
      self.with_hierarchy unless self.hierarchy_id && self.eff_time
      Fdn::Organization.s_ancestors(self.hierarchy_id, self.eff_time, self.id)
    end

    #所有下级组织
    #数据经过组织为{1:[], 2:[], 3[], 4,[]} key是距离，如果只想要组织的列表，不需要组织数据，see: all_descendants
    def descendants
      result = {}
      self.with_hierarchy unless self.hierarchy_id && self.eff_time
      orgs = Fdn::Organization.s_descendants(self.hierarchy_id, self.eff_time, self.id)
      orgs.each do |o|
        result[o.f_distance.to_s] ||= []
        result[o.f_distance.to_s] << o
      end
      result
    end

    #相对关系
    #pos: +1，-1，+2，-3等与本组织的关系
    def rel_organizations(pos)
      self.with_hierarchy unless self.hierarchy_id && self.eff_time
      if matches = pos.match(/([\+-])(\d+)/)
        if matches[1] == '+'
          Fdn::Organization.s_parent_by_dis(self.hierarchy_id, self.eff_time, self.id, matches[2])
        else
          Fdn::Organization.s_children_by_dis(self.hierarchy_id, self.eff_time, self.id, matches[2])
        end
      end
    end

    #本级组织除本组织外的其他组织
    def siblings
      self.with_hierarchy unless self.hierarchy_id && self.eff_time
      my_parent = self.parent
      if my_parent
        Fdn::Organization.s_children(self.hierarchy_id, self.eff_time, my_parent.id).delete_if { |o| o.id == self.id }
      end
    end

    #作为根节点添加
    def add_as_root
      self.with_hierarchy unless self.hierarchy_id && self.eff_time
      org_hie = Fdn::OrgHierarchy.find(self.hierarchy_id)
      if org_hie.org_hie_elements.empty?
        return self if org_hie.org_hie_elements.create(:parent_id => self.id,
                                                       :child_id => self.id,
                                                       :root_id => self.id,
                                                       :distance => 0,
                                                       :seq => 0,
                                                       :start_time => self.eff_time,
                                                       :end_time => Fdn::OrgHieElement::NEVER_END_TIME)
      else
        raise Fdn::Exceptions::HierarchyNotNullException
      end

    end

    #添加子节点
    #
    def add_child(organization_id, no_seq=false, seq=nil)
      self.with_hierarchy unless self.hierarchy_id && self.eff_time
      org_hie = Fdn::OrgHierarchy.find(self.hierarchy_id)
      new_org = Fdn::Organization.find(organization_id).with_hierarchy(self.hierarchy_id, self.eff_time)
      if new_org.root.blank?
        logger.info("begin add #{organization_id}")
        logger.info("begin add #{self.id}")
        Fdn::Organization.transaction do
          Fdn::OrgHieElement.need_disabled_by_child(self.hierarchy_id, organization_id, self.eff_time).each do |ele|
            ele.disable(self.eff_time)
          end

          ele = org_hie.org_hie_elements.create(:parent_id => self.id,
                                                :child_id => organization_id,
                                                :root_id => self.root.id,
                                                :distance => 1)
          ele.insert_at(seq) if seq && !no_seq
          ele.enable(self.eff_time)
          self.ancestors.each do |o|
            logger.info("ancestor: #{o.id}")
            ele = org_hie.org_hie_elements.create(:parent_id => o.id,
                                                  :child_id => organization_id,
                                                  :root_id => self.root.id,
                                                  :distance => o.f_distance+1)
            ele.insert_at(seq) if seq && !no_seq
            ele.enable(self.eff_time)
          end
        end

        logger.info("end add #{organization_id}")
        Fdn::Organization.find(organization_id).with_hierarchy(self.hierarchy_id, self.eff_time)
      else
        raise Fdn::Exceptions::OrgExistsException
      end
    end

    #改变上级组织
    def change_parent(organization_id, seq=nil)
      self.with_hierarchy unless self.hierarchy_id && self.eff_time
      org_hie = Fdn::OrgHierarchy.find(self.hierarchy_id)
      if self.root.blank?
        raise Fdn::Exceptions::OrgNotExistsException
      else
        #只有改变了父节点才执行操作
        if self.parent.id != organization_id
          old_descendants = self.all_descendants
          new_parent = Fdn::Organization.find(organization_id).with_hierarchy(self.hierarchy_id, self.eff_time)
          #new_parent_ancestors = new_parent.ancestors
          Fdn::Organization.transaction do
            remove_selves_elements_from_tree

            new_parent.add_child(self.id, nil, seq)
            #curr_version.org_hie_elements.create(:parent_id=>organization_id, :child_id=>self.id, :root_id=>new_parent.root.id, :distance=>1)
            new_parents = self.ancestors
            new_parents.each do |p|
              old_descendants.each do |o|

                org_hie.org_hie_elements.create(:parent_id => p.id,
                                                :root_id => p.root.id,
                                                :child_id => o.id,
                                                :seq => o.seq,
                                                :distance => new_parents.index(p) + k.to_i + 1).enable(self.eff_time)
              end

            end
          end
          new_parent
        else
          self
        end
      end

    end

    #将本组织的位置替换为...
    #一般不会用到
    def replaced_by(organization_id)
      self.with_hierarchy unless self.hierarchy_id && self.eff_time
      org_hie = Fdn::OrgHierarchy.find(self.hierarchy_id)
      new_org = Fdn::Organization.find(organization_id).with_hierarchy(self.hierarchy_id, self.eff_time)
      if new_org.root.blank?
        old_descendants = self.descendants
        new_parent = self.parent
        new_parents = self.ancestors
        #new_parent_ancestors = new_parent.ancestors
        Fdn::Organization.transaction do
          remove_selves_elements_from_tree

          new_parent.add_child(organization_id, nil, self.seq)
          #curr_version.org_hie_elements.create(:parent_id=>organization_id, :child_id=>self.id, :root_id=>new_parent.root.id, :distance=>1)

          new_parents.each do |p|
            old_descendants.each do |k, v|
              v.each do |o|
                org_hie.org_hie_elements.create(:parent_id => p.id,
                                                :root_id => p.root.id,
                                                :child_id => o.id,
                                                :seq => o.seq,
                                                :distance => new_parents.index(p) + k.to_i + 1).enable(self.eff_time)
              end
            end
          end
        end
        new_org
      else
        raise Fdn::Exceptions::OrgExistsException
      end
    end

    #将本组织从树中删除
    def remove_self
      self.with_hierarchy unless self.hierarchy_id && self.eff_time
      org_hie = Fdn::OrgHierarchy.find(self.hierarchy_id)
      if self.root.blank?
        raise Fdn::Exceptions::OrgNotExistsException
      else
        Fdn::Organization.transaction do
          remove_selves_elements_from_tree
        end
        self
      end

    end

    private

    def remove_selves_elements_from_tree
      Fdn::OrgHieElement.need_disabled_by_child(self.hierarchy_id, self.id, self.eff_time).each do |ele|
        ele.disable(self.eff_time)
      end
      Fdn::OrgHieElement.need_disabled_by_parent(self.hierarchy_id, self.id, self.eff_time).each do |ele|
        ele.disable(self.eff_time)
      end
    end

  end
end