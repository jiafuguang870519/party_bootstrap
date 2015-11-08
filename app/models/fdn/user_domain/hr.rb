module Fdn::UserDomain::Hr
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      #######
      #各种层次的join
      #scope :join_per, joins('inner join hr_people on hr_people.id = fdn_users.person_id ')
      #scope :join_ass, join_per.joins('inner join hr_assignments on hr_people.id = hr_assignments.person_id')

      #scope :join_dept, join_ass.joins('inner join fdn_organizations on hr_assignments.organization_id = fdn_organizations.id
      #inner join fdn_depts on fdn_organizations.resource_id = fdn_depts.id and fdn_organizations.resource_type=\'Fdn::Dept\'')

      #scope :join_pos, join_ass.joins('inner join hr_positions on hr_assignments.position_id = hr_positions.id
      #  ')

      #scope :join_positive_str, join_pos.joins('inner join hr_pos_str_elements on hr_pos_str_elements.parent_id = hr_positions.id
      #    inner join hr_pos_str_versions on hr_pos_str_versions.id = hr_pos_str_elements.pos_str_version_id')

      #scope :join_negative_str, join_pos.joins('inner join hr_pos_str_elements on hr_pos_str_elements.child_id = hr_positions.id
      #    inner join hr_pos_str_versions on hr_pos_str_versions.id = hr_pos_str_elements.pos_str_version_id')

      #scope :join_job, join_ass.joins('inner join hr_jobs on hr_assignments.job_id = hr_jobs.id
      #  ')

      ########
      #引用各种层次的join简化sql
      #scope :by_dept, lambda { |dept_ids| join_dept.where("hr_assignments.end_date is null and fdn_depts.id in (?)", dept_ids) }

      #scope :by_dept_code, lambda { |dept_codes| join_dept.where("hr_assignments.end_date is null and fdn_depts.internal = 1 and fdn_organizations.code in (?)", dept_codes) }


      #scope :by_pos, lambda { |pos_ids| join_pos.where("hr_assignments.end_date is null and hr_positions.id in (?)", pos_ids) }

      #scope :by_positive_pos, lambda { |pos_id, distance, structure_id|
      #  join_pos.join_positive_str.where(
      #      'hr_pos_str_elements.child_id = ? and hr_pos_str_elements.distance<=? and hr_pos_str_elements.child_id <> hr_pos_str_elements.parent_id
      #       and hr_pos_str_versions.position_structure_id=? and hr_pos_str_versions.end_date is null', pos_id, distance, structure_id) }

      #scope :by_negative_pos, lambda { |pos_id, distance, structure_id|
      #  join_pos.join_negative_str.where(
      #      'hr_pos_str_elements.parent_id = ? and hr_pos_str_elements.distance<=? and hr_pos_str_elements.child_id <> hr_pos_str_elements.parent_id
      #       and hr_pos_str_versions.position_structure_id=? and hr_pos_str_versions.end_date is null', pos_id, distance, structure_id) }
      #
      #scope :by_pos_code, lambda { |pos_codes| join_pos.where("hr_assignments.end_date is null and hr_positions.code in (?)", pos_codes) }
      #scope :by_rel_pos_code, lambda { |org_id, pos_codes|
      #  org = Fdn::Organization.find(org_id)
      #  if pos_codes.is_a?(Array)
      #    s = join_pos.where("hr_assignments.end_date is null ")
      #    where_str = []
      #    pos_codes.each do |c|
      #      where_str << "hr_positions.code = '#{org.code}.#{c}'"
      #    end
      #    s = s.where(where_str.join(' or '))
      #  else
      #    s = join_pos.where("hr_assignments.end_date is null and hr_positions.code = ?", "#{org.code}.#{pos_codes}")
      #  end
      #  s
      #}
      #
      #scope :by_job, lambda { |job_ids| join_job.where("hr_assignments.end_date is null and hr_jobs.id in (?)", job_ids) }
      #
      #scope :by_job_code, lambda { |job_codes| join_job.where("hr_assignments.end_date is null and hr_jobs.code in (?)", job_codes) }
      #
      #scope :by_rel_job_code, lambda { |org_id, job_codes| join_job.where("hr_assignments.end_date is null and hr_assignments.organization_id = ? and hr_jobs.code in (?)", org_id, job_codes) }
      #
      #scope :by_orgs_and_jobs, lambda { |org_ids, job_codes| join_job.where(
      #    "hr_assignments.end_date is null and hr_assignments.organization_id in (?) and hr_jobs.code in (?)",
      #    org_ids, job_codes) }
    end
  end

  module ClassMethods
    #各处室处长用户
    def leaders_of_dept
      by_pos_code(Hr::Position.pos_in_charge).order('seq')
    end

    def find_by_full_name(full_name)
      by_full_name(full_name).first
    end
  end

  def with_assignment(params)
    if user.person_id
      self.curr_assignment = Hr::Assignment.with_params(params)
    end
  end

  def primary_assignment
    self.person.primary_assignment if self.person_id
  end

  def primary_org
    primary_assignment.organization if primary_assignment
  end

  #主要分配所在处室名称
  def primary_org_name
    primary_org.short_name
  end

  def primary_org_code
    primary_org.code
  end

  def primary_job
    primary_assignment.job if primary_assignment
  end

  #主要担任职位所在处室名称
  def primary_pos_org_name
    if primary_pos
      Fdn::Organization.find_by_code(primary_pos.code[0..primary_pos.code.index('.')-1]).short_name
    end
  end

  def primary_pos
    primary_assignment.position if primary_assignment
  end

  #所有分配
  def assignments
    person.assignments if person_id
  end

  #所在处室
  def organizations
    person.assignments.map { |a| a.organization }.uniq if person_id
  end

  #职位列表
  def positions
    person.assignments.map { |a| a.position }.uniq if person_id
  end

  #监管处室
  def supervise_orgs
    orgs = []
    positions.each do |p|
      if p.code.end_with?('001') && p.code != 'WLD.001'
        orgs << Fdn::Organization.find_by_code(p.code[0..p.code.index('.')-1])
      end

      p.with_hierarchy
      #logger.info("ppp: #{p.descendants.values.inspect}")
      sub_pos = p.descendants.values.flatten.select { |p| p.code.end_with?('001') }
      if sub_pos && sub_pos.size > 0
        orgs = Fdn::Organization.in_codes(sub_pos.map { |sp| sp.code[0..sp.code.index('.')-1] })
      end
    end
    orgs.uniq
  end

  #监管人员
  def supervise_users
    orgs = supervise_orgs
    Fdn::User.by_dept_code(orgs.map { |o| o.code }) unless orgs.empty?
  end

  def get_profile_value(profile_code)
    Fdn::Profile.get_value(profile_code, self)
  end
end